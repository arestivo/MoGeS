package com.aor.moges.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class MogesChannel implements Runnable{
	private final Socket mSocket;
	private final String mProtocol;

	private PrintWriter mOutWriter;
	private BufferedReader mInBuffer;
	
	private boolean mDisconnect = false;

	public MogesChannel(String protocol, Socket socket) {
		this.mProtocol = protocol;
		this.mSocket = socket;
	}

	public void run() {
		try {
	        System.out.println("[MoGeS] Connection Opened: " + mProtocol);
			mOutWriter = new PrintWriter(mSocket.getOutputStream(), true);
	        mInBuffer = new BufferedReader(new InputStreamReader(mSocket.getInputStream()));
	 
	        connected();
	        
	        mOutWriter.close();
	        mInBuffer.close();
	        mSocket.close();
	        System.out.println("[MoGeS] Connection Closed");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void disconnect() {
		mDisconnect  = true;
	}

	private void connected() throws IOException {
		String line;
		while (!mDisconnect && (line = mInBuffer.readLine()) != null) {
			lineReceived(line.trim());
		}
	}
	
	protected void lineReceived(String line) {
		System.out.println("[MoGeS] Received: " + line);
	}

	public void sendLine(String line) {
		mOutWriter.println(line.trim());
		System.out.println("[MoGeS] Sent: " + line.trim());
	}

	public String getProtocol() {
		return mProtocol;
	}

}
