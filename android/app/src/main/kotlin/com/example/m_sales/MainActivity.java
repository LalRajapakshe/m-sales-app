package com.example.m_sales;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import com.rt.printerlibrary.bean.BluetoothEdrConfigBean;
import com.rt.printerlibrary.cmd.Cmd;
import com.rt.printerlibrary.cmd.EscFactory;
import com.rt.printerlibrary.connect.PrinterInterface;
import com.rt.printerlibrary.enumerate.BmpPrintMode;
import com.rt.printerlibrary.enumerate.CommonEnum;
import com.rt.printerlibrary.exception.SdkException;
import com.rt.printerlibrary.factory.cmd.CmdFactory;
import com.rt.printerlibrary.factory.connect.BluetoothFactory;
import com.rt.printerlibrary.factory.connect.PIFactory;
import com.rt.printerlibrary.factory.printer.PrinterFactory;
import com.rt.printerlibrary.factory.printer.ThermalPrinterFactory;
import com.rt.printerlibrary.printer.RTPrinter;
import com.rt.printerlibrary.setting.BitmapSetting;
import com.rt.printerlibrary.setting.CommonSetting;
import com.rt.printerlibrary.utils.ConnectListener;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "printer_service";
    private static final String PRINTER_DISCOVERY_CHANNEL = "printer_service/discovery";

    private Context mContext;

    private EventChannel.EventSink eventSink;

    private BroadcastReceiver mBluetoothReceiver;
    private IntentFilter mBluetoothIntentFilter;
    private BluetoothAdapter mBluetoothAdapter;
    private List<BluetoothDevice> foundDeviceList = new ArrayList<>();

    private RTPrinter rtPrinter = null;
    private PrinterFactory printerFactory;


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        mContext = this;

        // Register the EventChannel handler ONCE, outside the method handler
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PRINTER_DISCOVERY_CHANNEL)
            .setStreamHandler(new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object arguments, EventChannel.EventSink events) {
                    eventSink = events;
                }

                @Override
                public void onCancel(Object arguments) {
                    eventSink = null;
                    if (mBluetoothReceiver != null) {
                        unregisterReceiver(mBluetoothReceiver);
                    }
                }
            });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals("printPdf")) {
                final String deviceBtAddress = call.argument("deviceBtAddress");
                final List<String> filePaths = call.argument("filePaths");

                printPdf(deviceBtAddress, filePaths, result);
            } else if (call.method.equals("discoverPrinters")) {
                discoverPrinters(result);
            } else {
                result.notImplemented();
            }
        });
    }

    private void printPdf(String deviceBtAddress, List<String> filePaths, MethodChannel.Result result) {
        printerFactory = new ThermalPrinterFactory();
        rtPrinter = printerFactory.create();
        final BluetoothDevice device = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(deviceBtAddress);
        final BluetoothEdrConfigBean bluetoothEdrConfigBean = new BluetoothEdrConfigBean(device);
        final PIFactory piFactory = new BluetoothFactory();
        final PrinterInterface printerInterface = piFactory.create();
        printerInterface.setConfigObject(bluetoothEdrConfigBean);
        rtPrinter.setPrinterInterface(printerInterface);
        rtPrinter.setConnectListener(new ConnectListener() {
            @Override
            public void onPrinterConnected(Object configObj) {
                System.out.println("onPrinterConnected");
                try {
                    final List<Bitmap> bitmaps = new ArrayList<>();
                    for (String filePath : filePaths) {
                        final File file = new File(filePath);
                        final Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
                        bitmaps.add(bitmap);
                    }
                    escPrint(bitmaps);
                    result.success("Printed Successfully");
                } catch (Exception e) {
                    result.error("ERROR", "Failed to print PDF: " + e.getMessage(), null);
                }
            }

            @Override
            public void onPrinterDisconnect(Object configObj) {
                System.out.println("onPrinterDisconnect");
            }

            @Override
            public void onPrinterWritecompletion(Object configObj) {
                try {
                    Thread.sleep(5000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                rtPrinter.disConnect();
            }
        });

        try {
            rtPrinter.connect(bluetoothEdrConfigBean);
        } catch (Exception e) {
            result.error("BT_CONNECT", "Error connecting to device", e);
        }

    }

    private void escPrint(List<Bitmap> bitmaps) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                CmdFactory cmdFactory = new EscFactory();
                Cmd cmd = cmdFactory.create();
                cmd.append(cmd.getHeaderCmd());
                CommonSetting commonSetting = new CommonSetting();
                commonSetting.setAlign(CommonEnum.ALIGN_MIDDLE);
                cmd.append(cmd.getCommonSettingCmd(commonSetting));
                BitmapSetting bitmapSetting = new BitmapSetting();
                BmpPrintMode mode = BmpPrintMode.MODE_SINGLE_FAST;
                bitmapSetting.setBmpPrintMode(mode);
                bitmapSetting.setBimtapLimitWidth(90 * 8);
                for (final Bitmap bitmap : bitmaps) {
                    try {
                        cmd.append(cmd.getBitmapCmd(bitmapSetting, bitmap));
                    } catch (SdkException e) {
                        e.printStackTrace();
                    }
                    cmd.append(cmd.getLFCRCmd());
                    cmd.append(cmd.getCmdCutNew());

                }
                if (rtPrinter != null)
                    rtPrinter.writeMsgAsync(cmd.getAppendCmds());
            }
        }).start();

    }

    @SuppressLint("MissingPermission")
    private void discoverPrinters(MethodChannel.Result result) {
        foundDeviceList.clear();
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        mBluetoothReceiver = new BluetoothDeviceReceiver();
        mBluetoothReceiver = new BluetoothDeviceReceiver();
        mBluetoothIntentFilter = new IntentFilter();
        mBluetoothIntentFilter.addAction(BluetoothDevice.ACTION_FOUND);
        mBluetoothIntentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        mContext.registerReceiver(mBluetoothReceiver, mBluetoothIntentFilter);
        mBluetoothAdapter.startDiscovery();

        result.success(null);
    }

    private class BluetoothDeviceReceiver extends BroadcastReceiver {

        @SuppressLint("MissingPermission")
        @Override
        public void onReceive(Context context, Intent intent) {
           final  String action = intent.getAction();
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                @SuppressLint("MissingPermission") int devType = device.getBluetoothClass().getMajorDeviceClass();
              //  if (devType != BluetoothClass.Device.Major.IMAGING) {
              //      return;
              //  }

                if (!foundDeviceList.contains(device)) {
                    System.out.println("FOUND DEVICE: " + device.getName() + " TYPE: " + devType);
                    foundDeviceList.add(device);
                    if (eventSink != null) {
                        final Map<String, String> printerData = new HashMap<>();
                        printerData.put("address", device.getAddress());
                        printerData.put("name", device.getName());
                        eventSink.success(printerData);
                    }
                }
            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                mBluetoothAdapter.cancelDiscovery();
                mContext.unregisterReceiver(mBluetoothReceiver);
            }
        }
    }
}