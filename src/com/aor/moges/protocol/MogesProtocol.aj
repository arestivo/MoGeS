package com.aor.moges.protocol;

import com.aor.moges.server.MogesChannel;

public abstract aspect MogesProtocol {
	public pointcut connected(MogesChannel thread) : execution(* connected(..)) && this(thread);
	public pointcut received(MogesChannel thread, String line) : execution(* lineReceived(..)) && this(thread) && args(line);
}
