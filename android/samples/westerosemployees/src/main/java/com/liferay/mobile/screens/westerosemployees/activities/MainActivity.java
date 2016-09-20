/*
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.mobile.screens.westerosemployees.activities;

import android.content.Intent;
import android.os.Bundle;
import com.liferay.mobile.screens.auth.login.LoginListener;
import com.liferay.mobile.screens.auth.login.LoginScreenlet;
import com.liferay.mobile.screens.context.SessionContext;
import com.liferay.mobile.screens.context.User;
import com.liferay.mobile.screens.viewsets.westeros.WesterosSnackbar;
import com.liferay.mobile.screens.webcontent.display.WebContentDisplayScreenlet;
import com.liferay.mobile.screens.westerosemployees.R;
import com.liferay.mobile.screens.westerosemployees.utils.CardState;
import com.liferay.mobile.screens.westerosemployees.views.Deck;

public class MainActivity extends WesterosActivity implements LoginListener {

	private Deck deck;
	private LoginScreenlet loginScreenlet;
	private WebContentDisplayScreenlet webContentDisplayScreenlet;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		findViews();
		loadTerms();
	}

	private void findViews() {
		loginScreenlet = (LoginScreenlet) findViewById(R.id.login_screenlet);
		webContentDisplayScreenlet = (WebContentDisplayScreenlet) findViewById(R.id.web_content_display_screenlet);
		deck = (Deck) findViewById(R.id.deck);

		loginScreenlet.setListener(this);
	}

	private void loadTerms() {
		SessionContext.createBasicSession("test@liferay.com", "test");
		webContentDisplayScreenlet.load();
	}

	@Override
	public void onLoginSuccess(User user) {
		toNextActivity();
	}

	private void toNextActivity() {
		findViewById(R.id.background).animate().alpha(0f).withEndAction(new Runnable() {
			@Override
			public void run() {
				startActivity(new Intent(MainActivity.this, UserActivity.class));
			}
		});

		deck.setCardsState(CardState.HIDDEN);
	}

	@Override
	public void onLoginFailure(Exception e) {
		WesterosSnackbar.showSnackbar(this, "Login failed!", R.color.colorAccent_westeros);
	}
}