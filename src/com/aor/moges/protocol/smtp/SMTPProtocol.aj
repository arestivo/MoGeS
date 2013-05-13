package com.aor.moges.protocol.smtp;

import java.util.ArrayList;
import java.util.List;

import com.aor.moges.protocol.MogesProtocol;
import com.aor.moges.server.MogesChannel;

public aspect SMTPProtocol extends MogesProtocol{
	public static final String PROTOCOL = "SMTP";
	public static final int DEFAULT_PORT = 25;
	
	private static final int CODE_READY = 220;
	private static final int CODE_CLOSING = 221;
	private static final int CODE_OK = 250;
	private static final int CODE_DATA_INPUT = 354;
	private static final int CODE_ERROR_SYNTAX = 500;
	private static final int CODE_ERROR_ARGS = 501;
	
	private enum STATE {BEFORE_HELO, BEFORE_DATA, RECEIVING_DATA};
		
	private String mAddress = "localhost";
	
	private STATE mState = STATE.BEFORE_HELO;
	private String mDomain = null;
	private String mFrom = null;
	private List<String> mData = new ArrayList<String>();
	private List<String> mTo = new ArrayList<String>();
	
	public SMTPProtocol() {
		super();
	}

	before(MogesChannel channel): connected(channel) {
		if (channel.getProtocol().equals(PROTOCOL)) {
			channel.sendLine(CODE_READY + " " + mAddress + " MoGeS 1.0");
		}
	}

	before(MogesChannel channel, String line): received(channel, line) {
		if (channel.getProtocol().equals(PROTOCOL)) {
			if (mState == STATE.BEFORE_HELO) {
				if (line.equals("HELO") || line.startsWith("HELO ")) receiveHelo(channel, line);
				else if (line.equals("EHLO") || line.startsWith("EHLO ")) receiveHelo(channel, line);
				else channel.sendLine(CODE_ERROR_SYNTAX + " Expecting HELO or EHLO");
			} else if (mState == STATE.BEFORE_DATA) {
				if (line.startsWith("MAIL FROM:")) receiveMailFrom(channel, line);
				else if (line.startsWith("RCPT TO:")) receiveRcptTo(channel, line);
				else if (line.equals("DATA")) receiveData(channel, line);
				else channel.sendLine(CODE_ERROR_SYNTAX + " No idea what you are talking about");
			} else if (mState == STATE.RECEIVING_DATA) {
				receiveDataLine(channel, line);
			}
			if (line.equals("QUIT")) receiveQuit(channel, line);
		}
	}

	private void receiveDataLine(MogesChannel channel, String line) {
		if (line.trim().equals(".")) {
			channel.sendLine(CODE_OK + " Ok");
			transactionEnded(channel, mFrom, mTo, mData);
			mState = STATE.BEFORE_DATA;
		} else {
			mData.add(line);
		}
	}

	private void transactionEnded(MogesChannel channel, String from, List<String> to, List<String> data) {
	}

	private void receiveData(MogesChannel channel, String line) {
		channel.sendLine(CODE_DATA_INPUT + " End data with <CR><LF>.<CR><LF>");
		mState = STATE.RECEIVING_DATA;
	}

	private void receiveQuit(MogesChannel channel, String line) {
		channel.sendLine(CODE_CLOSING + " Bye");
		channel.disconnect();
	}

	private void receiveRcptTo(MogesChannel channel, String line) {
		if (line.indexOf(':') != -1 && line.length() > 10) {
			String rcptTo = line.substring(line.indexOf(':') + 1);
			rcptTo = rcptTo.trim();
			if (rcptTo.startsWith("<") && rcptTo.endsWith(">")) 
				rcptTo = rcptTo.substring(1, rcptTo.length() - 1);
			mTo.add(rcptTo);
			channel.sendLine(CODE_OK + " Ok");
		} else {
			channel.sendLine(CODE_ERROR_ARGS + " No mail recipient received");
		}
	}

	private void receiveMailFrom(MogesChannel channel, String line) {
		if (line.indexOf(':') != -1 && line.length() > 10) {
			mFrom = line.substring(line.indexOf(':') + 1);
			mFrom = mFrom.trim();
			if (mFrom.startsWith("<") && mFrom.endsWith(">")) 
				mFrom = mFrom.substring(1, mFrom.length() - 1);
			channel.sendLine(CODE_OK + " Ok");
		} else {
			channel.sendLine(CODE_ERROR_ARGS + " No mail sender received");
		}
	}

	private void receiveHelo(MogesChannel channel, String line) {
		if (line.indexOf(' ') != -1 && line.length() > 5)
			mDomain = line.substring(line.indexOf(' ') + 1);
		if (mDomain==null)
			channel.sendLine(CODE_OK + " Hello stranger");
		else
			channel.sendLine(CODE_OK + " Hello " + mDomain);
		mState = STATE.BEFORE_DATA;
	}

	public void setAddress(String address) {
		mAddress = address;
	}
}
