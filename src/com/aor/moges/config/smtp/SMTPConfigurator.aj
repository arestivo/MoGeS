package com.aor.moges.config.smtp;

import com.aor.moges.config.Configurator;
import com.aor.moges.protocol.smtp.SMTPProtocol;
import com.aor.moges.server.MogesServer;

public aspect SMTPConfigurator extends Configurator{	
	pointcut smtpProtocolInitialized(SMTPProtocol protocol): execution(SMTPProtocol.new(..)) && target(protocol);
	
	after (String protocol, int port, MogesServer server): serverStarted(protocol, port, server) {
		if (SMTPProtocol.PROTOCOL.equals(protocol)) {
			server.setPort(getIntProperty("smtp.port"));
		}
	}
	
	after(SMTPProtocol protocol): smtpProtocolInitialized(protocol) {
		protocol.setAddress(getStringProperty("smtp.address"));
	}
}
