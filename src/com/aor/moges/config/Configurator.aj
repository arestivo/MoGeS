package com.aor.moges.config;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

import com.aor.moges.server.MogesServer;

public abstract aspect Configurator {
	private static Properties properties = new Properties();

	static {
		try {
			properties.load(new FileInputStream(new File("config.properties")));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public pointcut serverStarted(String protocol, int port, MogesServer server) : execution(MogesServer.new(..)) && args(protocol, port) && target(server);
	
	public static String getStringProperty(String name) {
		return properties.getProperty(name);
	}

	public static int getIntProperty(String name) {
		return Integer.parseInt(properties.getProperty(name));
	}
}
