

package com.springmvc.service;

import java.util.Map;

public interface TasteProfileService {

	   void updateUserTasteProfile(String memberId);
	    Map<String, Double> getTasteScores(String memberId);
}
