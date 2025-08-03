package com.springmvc.domain;

import java.util.List;

//사용자의 취향 분석 리포트 전체를 담는 최상위 DTO

public class TasteReportDTO {

    // --- 리포트의 주요 섹션들 ---
    private String title;
    private Keywords keywords;
    private Analysis analysis;
    private FrequentPersons frequentPersons;
    private Preferences preferences;
    private String activityPattern;
    private Recommendation recommendation;
    private PotentialDesire potentialDesire;

    // --- 분석 전/후 상태를 관리하는 필드 ---
    private boolean isInitialReport = false;
    private String initialMessage;

    // --- 내부 클래스 정의 ---

    public static class Keywords {
        private List<String> topGenres;
        private String style;

        public List<String> getTopGenres() { return topGenres; }
        public void setTopGenres(List<String> topGenres) { this.topGenres = topGenres; }

        public String getStyle() { return style; }
        public void setStyle(String style) { this.style = style; }


   
    }

    private String styleDescription;
    public String getStyleDescription() { return styleDescription; }
    public void setStyleDescription(String styleDescription) { this.styleDescription = styleDescription; }

    public static class Analysis {
        private List<String> strengths;
        private List<String> weaknesses;
        private String specialInsight;
        // Getters & Setters
        public List<String> getStrengths() { return strengths; }
        public void setStrengths(List<String> strengths) { this.strengths = strengths; }
        public List<String> getWeaknesses() { return weaknesses; }
        public void setWeaknesses(List<String> weaknesses) { this.weaknesses = weaknesses; }
        public String getSpecialInsight() { return specialInsight; }
        public void setSpecialInsight(String specialInsight) { this.specialInsight = specialInsight; }
    }
    
    public static class Person {
        private Long id;
        private String name;
        private String imageUrl;
        public Person(Long id, String name, String imageUrl) { this.id = id; this.name = name; this.imageUrl = imageUrl; }
        // Getters
        public Long getId() { return id; }
        public String getName() { return name; }
        public String getImageUrl() { return imageUrl; }
    }
    
    public static class FrequentPersons {
        private Person mostReviewedActor;
        private Person highlyRatedActor;
        private Person mostReviewedDirector;
        private Person highlyRatedDirector;
        

        public Person getMostReviewedActor() { return mostReviewedActor; }
        public void setMostReviewedActor(Person mostReviewedActor) { this.mostReviewedActor = mostReviewedActor; }
        public Person getHighlyRatedActor() { return highlyRatedActor; }
        public void setHighlyRatedActor(Person highlyRatedActor) { this.highlyRatedActor = highlyRatedActor; }
        public Person getMostReviewedDirector() { return mostReviewedDirector; }
        public void setMostReviewedDirector(Person mostReviewedDirector) { this.mostReviewedDirector = mostReviewedDirector; }
        public Person getHighlyRatedDirector() { return highlyRatedDirector; }
        public void setHighlyRatedDirector(Person highlyRatedDirector) { this.highlyRatedDirector = highlyRatedDirector; }
    }

    public static class Preferences {
        private String preferredYear;
        private String preferredRuntime;

        public String getPreferredYear() { return preferredYear; }
        public void setPreferredYear(String preferredYear) { this.preferredYear = preferredYear; }
        public String getPreferredRuntime() { return preferredRuntime; }
        public void setPreferredRuntime(String preferredRuntime) { this.preferredRuntime = preferredRuntime; }
    }
    
    public static class Recommendation {
        private String safeBet;
        private String adventurousChoice;
        // Getters & Setters
        public String getSafeBet() { return safeBet; }
        public void setSafeBet(String safeBet) { this.safeBet = safeBet; }
        public String getAdventurousChoice() { return adventurousChoice; }
        public void setAdventurousChoice(String adventurousChoice) { this.adventurousChoice = adventurousChoice; }
    }
    
    // --- 최상위 DTO의 생성자, Getters & Setters ---
    
    public TasteReportDTO() {
        this.keywords = new Keywords();
        this.analysis = new Analysis();
        this.frequentPersons = new FrequentPersons();
        this.preferences = new Preferences();
        this.recommendation = new Recommendation();
    }
    
    // 최상위 필드에 대한 Getters & Setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Keywords getKeywords() { return keywords; }
    public void setKeywords(Keywords keywords) { this.keywords = keywords; }
    public Analysis getAnalysis() { return analysis; }
    public void setAnalysis(Analysis analysis) { this.analysis = analysis; }
    public FrequentPersons getFrequentPersons() { return frequentPersons; }
    public void setFrequentPersons(FrequentPersons frequentPersons) { this.frequentPersons = frequentPersons; }
    public Preferences getPreferences() { return preferences; }
    public void setPreferences(Preferences preferences) { this.preferences = preferences; }
    public String getActivityPattern() { return activityPattern; }
    public void setActivityPattern(String activityPattern) { this.activityPattern = activityPattern; }
    public Recommendation getRecommendation() { return recommendation; }
    public void setRecommendation(Recommendation recommendation) { this.recommendation = recommendation; }
    public boolean isInitialReport() { return isInitialReport; }
    public void setInitialReport(boolean isInitialReport) { this.isInitialReport = isInitialReport; }
    public String getInitialMessage() { return initialMessage; }
    public void setInitialMessage(String initialMessage) { this.initialMessage = initialMessage; }
    
    

   

    // 찜 기능과 연관된 분석 
    public PotentialDesire getPotentialDesire() { return potentialDesire; }
    public void setPotentialDesire(PotentialDesire potentialDesire) { this.potentialDesire = potentialDesire; }

    public static class PotentialDesire {
        private String title;
        private String message;
        private int priority;
        
        public PotentialDesire(String title, String message, int priority) {
            this.title = title;
            this.message = message;
            this.priority = priority;
        }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public int getPriority() { return priority; }
		public void setPriority(int priority) {
			this.priority = priority;
		  }

		}
        
        
    }