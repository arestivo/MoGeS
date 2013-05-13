package com.aor.moges.mbox;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import com.aor.moges.protocol.smtp.SMTPProtocol;
import com.aor.moges.server.MogesChannel;

public aspect MboxStorage {
	private static String mFolder = "/home/arestivo/mbox";
	
	public static void setFolder(String folder) {
		mFolder = folder;
	}
	
	pointcut transactionEnded(MogesChannel channel, String from, List<String> to, List<String> data): execution(* SMTPProtocol.transactionEnded(..)) && args(channel, from, to, data);
	
	after(MogesChannel channel, String from, List<String> to, List<String> data):  transactionEnded(channel, from, to, data){
		DateFormat format = new SimpleDateFormat("EEE MMM dd HH:mm:ss yyyy", Locale.ENGLISH);
        format.setLenient(false);		
        for (String email : to) {
			String username = email.substring(0, email.indexOf("@"));
			try {
				BufferedWriter output = new BufferedWriter(new FileWriter(mFolder + "/" + username, true));
				output.write("From " + from + " " + format.format(new Date()) + "\n");
				output.write("From: <" + from + "> " + "\n");
				output.write("To: <" + email + "> " + "\n");
				for (String line : data) {
					output.write(line + "\n");
				}
				output.write("\n");
				output.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}
