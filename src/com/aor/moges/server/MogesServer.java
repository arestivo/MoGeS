package com.aor.moges.server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class MogesServer {
	private ServerSocket mServerSocket;
	private String mProtocol;
	private int mPort;
	private String mAddress;
	
	public MogesServer(String protocol, int port) {
		this.mProtocol = protocol;
		this.mPort = port;
	}
	
	public void start() throws IOException {
		mServerSocket = new ServerSocket(mPort);
		System.out.println("[MoGeS] Accepting Connections [" + mPort + "]");
		while (true) {
			Socket socket = mServerSocket.accept();
			new Thread(new MogesChannel(mProtocol, socket)).run();
		}
	}

	public void setPort(int port) {
		mPort = port;
	}

	public void setAddress(String address) {
		this.mAddress = address;
	}
}
