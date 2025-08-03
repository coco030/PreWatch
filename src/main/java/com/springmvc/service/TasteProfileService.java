

package com.springmvc.service;

import java.util.Map;

import com.springmvc.domain.TasteReportDTO;

public interface TasteProfileService {

	 TasteReportDTO updateUserTasteProfile(String memberId);
	   Map<String, Double> getTasteScores(String memberId);
}
