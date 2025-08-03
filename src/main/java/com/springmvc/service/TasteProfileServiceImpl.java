package com.springmvc.service;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.domain.TasteReportDTO;
import com.springmvc.repository.MemberRepository;
import com.springmvc.repository.StatRepository;
import com.springmvc.repository.UserReviewRepository;

@Service
public class TasteProfileServiceImpl implements TasteProfileService {

    @Autowired
    private StatRepository statRepository;
    @Autowired
    private UserReviewRepository userReviewRepository;
    @Autowired
    private MemberRepository memberRepository;
    @Autowired
    private StatService statService;
    
    @Override
    public TasteReportDTO updateUserTasteProfile(String memberId) {
        System.out.println("\n===== [START] 취향 프로필 업데이트 (MEMBER ID: " + memberId + ") =====");
        
        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);
        
        // 리뷰 5개 미만이면, 분석하지 않고 null을 반환.
        if (reviewedMovies == null || reviewedMovies.size() < 5) {
            System.out.println("[INFO] 리뷰 개수가 부족하여 초기 프로필을 생성합니다.");
            memberRepository.updateTasteProfile(memberId, "취향 탐색 중...", "아직 평가가 부족해요. 5편 이상의 영화를 평가하면 당신만의 취향 리포트가 생성됩니다.", 0.0);
            System.out.println("===== [END] 취향 프로필 업데이트 =====\n");
            return null;
        }
        System.out.println("[STEP 1] 정밀 분석 시작 (리뷰 " + reviewedMovies.size() + "개)");

        TasteReportDTO reportDTO = new TasteReportDTO();

        // 1. 핵심 분석 지표 계산
        Map<String, Double> deviationScores = statService.calculateUserDeviationScores(memberId);
        double consistencyScore = calculateConsistency(reviewedMovies);
        
        System.out.println("[STEP 2] 핵심 지표 계산 완료");
        System.out.println("  > 편차 점수(Deviation Scores): " + deviationScores);
        System.out.printf("  > 취향 일관성 점수(Consistency Score): %.2f%n", consistencyScore);

        // 2. Repository에서 추가 데이터 조회
        System.out.println("[STEP 3] Repository에서 추가 데이터 조회 시작...");
        String signatureGenre = userReviewRepository.findSignatureGenre(memberId);
        Map<String, String> favoritePerson = userReviewRepository.findFavoritePerson(memberId);
        String activityPattern = userReviewRepository.findActivityPattern(memberId);
        Map<String, Double> metaPreference = userReviewRepository.findMoviePreferenceMeta(memberId);
        List<String> topGenres = findTopGenres(reviewedMovies, 3);
        System.out.println("  > 시그니처 장르: " + signatureGenre);
        System.out.println("  > 선호 인물: " + favoritePerson);
        System.out.println("  > 활동 패턴: " + activityPattern);
        System.out.println("  > 영화 메타 선호도: " + metaPreference);

        // 3. 조회된 데이터를 DTO에 채우기
        System.out.println("[STEP 4] DTO 객체에 데이터 채우기 시작...");
        reportDTO.setTitle(createFinalTitle(signatureGenre, favoritePerson));
        reportDTO.setTopGenres(topGenres);
        reportDTO.setUserStyle(consistencyScore > 7.5 ? "#확고한편" : (consistencyScore < 4.0 ? "#다양한편" : "#밸런스형"));
        reportDTO.setStrengthKeywords(getKeysByCondition(deviationScores, score -> score > 1.0));
        reportDTO.setWeaknessKeywords(getKeysByCondition(deviationScores, score -> score < -1.0));
        reportDTO.setSpecialInsight(findSpecialInsight(deviationScores));

        if (favoritePerson != null) {
            reportDTO.setFavoritePersonName(favoritePerson.get("name"));
            reportDTO.setFavoritePersonRole(favoritePerson.get("role").equalsIgnoreCase("ACTOR") ? "배우" : "감독");
        }
        if (metaPreference != null) {
            reportDTO.setPreferredYear(formatYear(metaPreference.get("avgYear")));
            reportDTO.setPreferredRuntime(formatRuntime(metaPreference.get("avgRuntime")));
        }
        reportDTO.setActivityPattern(activityPattern != null ? String.format("%s에 주로 활동하는 당신", activityPattern) : null);
        createRecommendation(reportDTO, deviationScores, topGenres);
        System.out.println("  > 생성된 타이틀: " + reportDTO.getTitle());

        // 4. DB에 일부 정보 업데이트
        memberRepository.updateTasteProfile(memberId, reportDTO.getTitle(), "상세 리포트가 생성되었습니다. 마이페이지에서 확인하세요.", 0.0);
        System.out.println("[STEP 5] DB에 프로필 업데이트 완료.");
        System.out.println("===== [END] 취향 프로필 업데이트 =====\n");

        return reportDTO;
    }

    @Override
    public Map<String, Double> getTasteScores(String memberId) {
        return statService.calculateUserDeviationScores(memberId);
    }

    // --- 헬퍼 메소드들 ---

    private String createFinalTitle(String signatureGenre, Map<String, String> favoritePerson) {
        if (favoritePerson != null && signatureGenre != null) {
            return String.format("%s의 페르소나, %s 전문가", favoritePerson.get("name"), signatureGenre);
        } else if (signatureGenre != null) {
            return String.format("%s 장르의 확고한 지지자", signatureGenre);
        }
        return "다채로운 취향의 소유자";
    }

    private void createRecommendation(TasteReportDTO reportDTO, Map<String, Double> deviationScores, List<String> topGenres) {
        if (topGenres.isEmpty()) {
            reportDTO.setBestBetRecommendation("다양한 장르의 명작들을 감상하며 당신의 대표 장르를 찾아보세요.");
            reportDTO.setAdventurousRecommendation("평점이 높은 영화부터 시작하는 것이 좋은 방법입니다.");
            return;
        }
        String topGenre = topGenres.get(0);
        
        if (!reportDTO.getStrengthKeywords().isEmpty()) {
            String strength = reportDTO.getStrengthKeywords().get(0);
            reportDTO.setBestBetRecommendation(String.format("<strong>%s</strong> 장르 중 <strong>%s</strong>이(가) 돋보이는 작품은 당신에게 최고의 만족을 줄 것입니다.", topGenre, strength));
        } else {
            reportDTO.setBestBetRecommendation(String.format("<strong>%s</strong> 장르의 인기작들을 감상하며 당신의 다음 '강점'을 발견해보세요.", topGenre));
        }

        if (!reportDTO.getWeaknessKeywords().isEmpty()) {
            String weakness = reportDTO.getWeaknessKeywords().get(0);
            reportDTO.setAdventurousRecommendation(String.format("당신이 민감한 '<strong>%s</strong>' 요소가 없는, 순수한 <strong>드라마</strong>나 <strong>코미디</strong> 장르는 어떠신가요?", weakness));
        } else if (topGenres.size() > 1) {
            reportDTO.setAdventurousRecommendation(String.format("당신의 또 다른 관심 장르인 <strong>%s</strong>에 도전하여 취향의 지도를 넓혀보세요.", topGenres.get(1)));
        } else {
            reportDTO.setAdventurousRecommendation("지금까지와는 다른 새로운 장르의 대표작을 감상하며 신선한 자극을 느껴보는 것을 추천합니다.");
        }
    }

    private List<String> getKeysByCondition(Map<String, Double> map, java.util.function.Predicate<Double> condition) {
        return map.entrySet().stream()
                .filter(entry -> condition.test(entry.getValue()))
                .map(Map.Entry::getKey)
                .sorted()
                .collect(Collectors.toList());
    }
    
    private String formatYear(Double avgYear) {
        if (avgYear == null || avgYear == 0) return null;
        int year = avgYear.intValue();
        if (year >= 2020) return "2020년대 최신 영화";
        if (year >= 2010) return "2010년대 영화";
        if (year >= 2000) return "2000년대 명작";
        if (year >= 1980) return "80-90년대 고전";
        return "시대를 초월한 명작";
    }

    private String formatRuntime(Double avgRuntime) {
        if (avgRuntime == null || avgRuntime == 0) return null;
        int runtime = avgRuntime.intValue();
        if (runtime >= 140) return "140분 이상의 긴 호흡";
        if (runtime >= 110) return "110~140분 사이의 표준 길이";
        return "110분 미만의 짧고 강렬한";
    }
    
    private List<String> findTopGenres(List<TasteAnalysisDataDTO> reviews, int limit) {
        Map<String, Integer> genreCounts = new HashMap<>();
        for (TasteAnalysisDataDTO review : reviews) {
            if(review.getMovieId() == null) continue;
            List<String> genres = statRepository.findGenresByMovieId(review.getMovieId());
            for (String genre : genres) {
                genreCounts.put(genre, genreCounts.getOrDefault(genre, 0) + 1);
            }
        }
        return genreCounts.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private double calculateConsistency(List<TasteAnalysisDataDTO> reviewedMovies) {
        if (reviewedMovies.size() < 2) return 5.0;
        List<Integer> myRatings = reviewedMovies.stream()
            .map(TasteAnalysisDataDTO::getMyUserRating)
            .filter(r -> r != null)
            .collect(Collectors.toList());
        double mean = myRatings.stream().mapToInt(Integer::intValue).average().orElse(0.0);
        double stdDev = Math.sqrt(myRatings.stream().mapToDouble(r -> Math.pow(r - mean, 2)).average().orElse(0.0));
        return Math.max(0, 10 - (stdDev * 3.33));
    }

    private String findSpecialInsight(Map<String, Double> deviationScores) {
        boolean lovesThriller = deviationScores.getOrDefault("스릴", 0.0) > 1.0;
        boolean hatesViolence = deviationScores.getOrDefault("액션", 0.0) < -1.0;
        boolean lovesAction = deviationScores.getOrDefault("액션", 0.0) > 1.0;
        boolean lovesRomance = deviationScores.getOrDefault("감성", 0.0) > 1.0;
        if (lovesThriller && hatesViolence) return "피 튀기는 장면 없이 심리적으로 옥죄는 스릴러에 깊이 매료되는, 고도의 집중력을 가진 감상가입니다.";
        if (lovesAction && lovesRomance) return "화려한 액션 속에서 피어나는 주인공들의 애틋한 감정선에 유독 깊게 몰입하는 특별한 감수성을 지니셨네요.";
        return null;
    }
    
    private String createInitialComment(List<TasteAnalysisDataDTO> reviewedMovies) {
        if (reviewedMovies == null || reviewedMovies.isEmpty()) {
            return "아직 평가한 영화가 없네요. 첫 평가를 남겨 당신의 취향을 알려주세요!";
        }
        return "현재 " + reviewedMovies.size() + "편의 영화에 대한 평가가 쌓였습니다. 정확한 분석을 위해 5편 이상의 평가가 필요합니다.";
    }
}