package com.aor.moges;

import java.io.IOException;

import com.aor.moges.server.MogesServer;

public class Moges {

	public static void main(String[] args) throws IOException {
		new MogesServer("SMTP", 2000).start();
	}
}
