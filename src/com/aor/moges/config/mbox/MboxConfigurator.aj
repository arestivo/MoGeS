package com.aor.moges.config.mbox;

import com.aor.moges.config.Configurator;
import com.aor.moges.mbox.MboxStorage;

public aspect MboxConfigurator extends Configurator{
	static {
		MboxStorage.setFolder(getStringProperty("mbox.folder"));
	}
}
