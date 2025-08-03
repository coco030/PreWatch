package com.springmvc.domain;

import java.util.List;
import java.util.Map;

public class TasteReportDTO {
	public TasteReportDTO() {};
	
    // 1. 타이틀
    private String title; // 예: "크리스토퍼 놀란의 페르소나, 작품성 중심의 스릴러 전문가"

    // 2. 취향 키워드
    private List<String> topGenres; // 예: ["스릴러", "드라마", "미스터리"]
    private String userStyle; // 예: "#확고한편", "#탐험가형"

    // 3. 상세 분석
    private List<String> strengthKeywords; // 강점 키워드 리스트 (예: ["작품성"])
    private List<String> weaknessKeywords; // 주의점 키워드 리스트 (예: ["감성"])
    private String specialInsight; // 특별한 발견 문장

    // 4. 선호 인물 (배우/감독)
    private String favoritePersonName; // 예: "크리스토퍼 놀란"
    private String favoritePersonRole; // 예: "감독"

    // 5. 영화 선택 스타일
    private String preferredYear; // 예: "2010년대 최신 영화"
    private String preferredRuntime; // 예: "120분 이상의 긴 호흡"

    // 6. 활동 패턴
    private String activityPattern; // 예: "주말 저녁 몰입형"

    // 7. 추천 가이드
    private String bestBetRecommendation; // 안전한 선택 추천 문장
    private String adventurousRecommendation; // 새로운 도전 추천 문장
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public List<String> getTopGenres() {
		return topGenres;
	}
	public void setTopGenres(List<String> topGenres) {
		this.topGenres = topGenres;
	}
	public String getUserStyle() {
		return userStyle;
	}
	public void setUserStyle(String userStyle) {
		this.userStyle = userStyle;
	}
	public List<String> getStrengthKeywords() {
		return strengthKeywords;
	}
	public void setStrengthKeywords(List<String> strengthKeywords) {
		this.strengthKeywords = strengthKeywords;
	}
	public List<String> getWeaknessKeywords() {
		return weaknessKeywords;
	}
	public void setWeaknessKeywords(List<String> weaknessKeywords) {
		this.weaknessKeywords = weaknessKeywords;
	}
	public String getSpecialInsight() {
		return specialInsight;
	}
	public void setSpecialInsight(String specialInsight) {
		this.specialInsight = specialInsight;
	}
	public String getFavoritePersonName() {
		return favoritePersonName;
	}
	public void setFavoritePersonName(String favoritePersonName) {
		this.favoritePersonName = favoritePersonName;
	}
	public String getFavoritePersonRole() {
		return favoritePersonRole;
	}
	public void setFavoritePersonRole(String favoritePersonRole) {
		this.favoritePersonRole = favoritePersonRole;
	}
	public String getPreferredYear() {
		return preferredYear;
	}
	public void setPreferredYear(String preferredYear) {
		this.preferredYear = preferredYear;
	}
	public String getPreferredRuntime() {
		return preferredRuntime;
	}
	public void setPreferredRuntime(String preferredRuntime) {
		this.preferredRuntime = preferredRuntime;
	}
	public String getActivityPattern() {
		return activityPattern;
	}
	public void setActivityPattern(String activityPattern) {
		this.activityPattern = activityPattern;
	}
	public String getBestBetRecommendation() {
		return bestBetRecommendation;
	}
	public void setBestBetRecommendation(String bestBetRecommendation) {
		this.bestBetRecommendation = bestBetRecommendation;
	}
	public String getAdventurousRecommendation() {
		return adventurousRecommendation;
	}
	public void setAdventurousRecommendation(String adventurousRecommendation) {
		this.adventurousRecommendation = adventurousRecommendation;
	}
	public TasteReportDTO(String title, List<String> topGenres, String userStyle, List<String> strengthKeywords,
			List<String> weaknessKeywords, String specialInsight, String favoritePersonName, String favoritePersonRole,
			String preferredYear, String preferredRuntime, String activityPattern, String bestBetRecommendation,
			String adventurousRecommendation) {
		super();
		this.title = title;
		this.topGenres = topGenres;
		this.userStyle = userStyle;
		this.strengthKeywords = strengthKeywords;
		this.weaknessKeywords = weaknessKeywords;
		this.specialInsight = specialInsight;
		this.favoritePersonName = favoritePersonName;
		this.favoritePersonRole = favoritePersonRole;
		this.preferredYear = preferredYear;
		this.preferredRuntime = preferredRuntime;
		this.activityPattern = activityPattern;
		this.bestBetRecommendation = bestBetRecommendation;
		this.adventurousRecommendation = adventurousRecommendation;
	}
	@Override
	public String toString() {
		return "TasteReportDTO [title=" + title + ", topGenres=" + topGenres + ", userStyle=" + userStyle
				+ ", strengthKeywords=" + strengthKeywords + ", weaknessKeywords=" + weaknessKeywords
				+ ", specialInsight=" + specialInsight + ", favoritePersonName=" + favoritePersonName
				+ ", favoritePersonRole=" + favoritePersonRole + ", preferredYear=" + preferredYear
				+ ", preferredRuntime=" + preferredRuntime + ", activityPattern=" + activityPattern
				+ ", bestBetRecommendation=" + bestBetRecommendation + ", adventurousRecommendation="
				+ adventurousRecommendation + "]";
	}
	
	
    
}