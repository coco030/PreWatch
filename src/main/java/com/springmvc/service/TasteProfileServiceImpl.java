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
import com.springmvc.repository.MemberRepository;
import com.springmvc.repository.StatRepository;

@Service
public class TasteProfileServiceImpl implements TasteProfileService {

    @Autowired
    private StatRepository statRepository;

    @Autowired
    private MemberRepository memberRepository;
    
    @Autowired
    private StatService statService;
    
    @Override
    public void updateUserTasteProfile(String memberId) {
        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);
        
        if (reviewedMovies == null || reviewedMovies.size() < 5) {
            memberRepository.updateTasteProfile(memberId, "취향 탐색 중...", "아직 평가가 부족해요. 5편 이상의 영화를 평가하면 당신만의 취향 리포트가 생성됩니다.", 0.0);
            return;
        }

        Map<String, Double> deviationScores = statService.calculateUserDeviationScores(memberId);
        List<String> topGenres = findTopGenres(reviewedMovies, 1); // Top 1 장르만 사용
        
        String finalTitle = createCoreTitle(deviationScores, topGenres);
        String finalReport = createCoreReport(deviationScores, topGenres);
        
        double anomalyScore = deviationScores.values().stream().mapToDouble(Math::abs).sum();
        memberRepository.updateTasteProfile(memberId, finalTitle, finalReport, anomalyScore);
    }

    @Override
    public Map<String, Double> getTasteScores(String memberId) {
        return statService.calculateUserDeviationScores(memberId);
    }

    /**
     * [최종 단순화 버전] 가장 핵심적인 키워드만으로 타이틀을 생성합니다.
     */
    private String createCoreTitle(Map<String, Double> deviationScores, List<String> topGenres) {
        // 1. 가장 편차가 큰 '핵심 취향'을 찾습니다.
        Map.Entry<String, Double> coreTasteEntry = deviationScores.entrySet().stream()
                .max(Comparator.comparing(entry -> Math.abs(entry.getValue())))
                .filter(entry -> Math.abs(entry.getValue()) > 1.2) // 편차가 1.2 이상일 때만 의미있다고 판단
                .orElse(null);

        String topGenre = topGenres.isEmpty() ? "다양한 장르의" : topGenres.get(0);

        // 2. '핵심 취향'이 있다면, 그것이 가장 중요한 정체성입니다.
        if (coreTasteEntry != null) {
            String coreTaste = coreTasteEntry.getKey();
            // 예시: "작품성 중심의 감상가", "액션을 선호하는 시네필"
            return String.format("%s 중심의 %s 전문가", coreTaste, topGenre);
        }
        
        // 3. '핵심 취향'이 없다면, 대표 장르가 정체성입니다.
        // 예시: "스릴러 장르의 애호가"
        return String.format("%s 장르의 애호가", topGenre);
    }


    /**
     * [최종 단순화 버전] 사용자가 이해하기 쉬운 실용적인 정보만으로 리포트를 구성합니다.
     */
    private String createCoreReport(Map<String, Double> deviationScores, List<String> topGenres) {
        StringBuilder report = new StringBuilder();

        // 1. 강점: 당신이 남들보다 더 좋아하는 것
        report.append("<p><strong>👍 당신의 강점</strong><br>");
        List<String> strengths = deviationScores.entrySet().stream()
                .filter(e -> e.getValue() > 1.0)
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        if (strengths.isEmpty()) {
            report.append("• 특정 요소에 치우치지 않는 균형 잡힌 시각을 가졌습니다.");
        } else {
            report.append(String.format("• 당신은 특히 <strong>%s</strong> 요소가 강한 영화에서 큰 만족을 느낍니다.", String.join(", ", strengths)));
        }
        report.append("</p>");

        // 2. 주의점: 당신이 남들보다 더 싫어할 수 있는 것
        report.append("<p><strong>⚠️ 주의할 점</strong><br>");
        List<String> weaknesses = deviationScores.entrySet().stream()
                .filter(e -> e.getValue() < -1.0)
                .sorted(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        if (weaknesses.isEmpty()) {
            report.append("• 특별히 기피하는 요소는 없으며, 다양한 영화를 편견 없이 즐길 수 있습니다.");
        } else {
            report.append(String.format("• <strong>%s</strong> 요소가 두드러지는 영화는 다른 사람들보다 불편하게 느낄 수 있으니 참고하세요.", String.join(", ", weaknesses)));
        }
        report.append("</p>");

        // 3. 추천 가이드: 그래서 다음 영화는?
        report.append("<p><strong>💡 다음 영화 선택 가이드</strong><br>");
        if (!topGenres.isEmpty()) {
            String topGenre = topGenres.get(0);
            if (!strengths.isEmpty()) {
                report.append(String.format("• <strong>%s</strong> 장르 중에서 <strong>%s</strong>(이)가 뛰어난 작품을 찾아보세요. 최고의 선택이 될 겁니다.", topGenre, strengths.get(0)));
            } else {
                report.append(String.format("• <strong>%s</strong> 장르의 높은 평점을 받은 명작들을 감상하며 당신의 다음 '강점'을 발견해보는 건 어떨까요?", topGenre));
            }
        } else {
            report.append("• 아직 당신의 대표 장르를 찾고 있습니다. 다양한 장르의 명작들을 감상하며 취향의 지도를 넓혀보세요.");
        }
        report.append("</p>");
        
        return report.toString();
    }
    

    /**
     * [추가된 헬퍼 메소드] 사용자가 리뷰한 영화들을 기반으로 가장 많이 본 장르 Top N을 찾습니다.
     */
    private List<String> findTopGenres(List<TasteAnalysisDataDTO> reviews, int limit) {
        Map<String, Integer> genreCounts = new HashMap<>();
        for (TasteAnalysisDataDTO review : reviews) {
            // review 객체에서 movieId를 가져와야 합니다.
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
        
        if (lovesThriller && hatesViolence) {
            return "잔인한 장면 없이 심리적으로 옥죄는 스릴러에 깊이 매료되는, 고도의 집중력을 가진 감상가입니다.";
        }
        if (lovesAction && lovesRomance) {
            return "화려한 액션 속에서 피어나는 주인공들의 애틋한 감정선에 유독 깊게 몰입하는 특별한 감수성을 지니셨네요.";
        }
        return "";
    }
    
    private String createInitialComment(List<TasteAnalysisDataDTO> reviewedMovies) {
        if (reviewedMovies == null || reviewedMovies.isEmpty()) {
            return "아직 평가한 영화가 없네요. 첫 평가를 남겨 당신의 취향을 알려주세요!";
        }
        String stageMessage = "현재 " + reviewedMovies.size() + "편의 영화에 대한 평가가 쌓였습니다. ";
        String base = "정확한 분석을 위해 5편 이상의 평가가 필요합니다. 당신의 다음 선택이 궁금하네요!";
        
        TasteAnalysisDataDTO latestReview = reviewedMovies.get(reviewedMovies.size() - 1);
        String firstImpression = createFirstImpression(latestReview);

        return stageMessage + firstImpression + " " + base;
    }
    
    private String createFirstImpression(TasteAnalysisDataDTO latestReview) {
        Integer violence = latestReview.getMyViolenceScore();
        Integer horror = latestReview.getMyHorrorScore();
        Integer sexual = latestReview.getMySexualScore();
        Integer rating = latestReview.getMyUserRating();

        if (violence != null && violence > 6) return "강렬한 액션으로 영화 여정을 시작하셨군요.";
        else if (horror != null && horror > 6) return "짜릿한 스릴과 함께 당신의 취향을 찾아가고 있네요.";
        else if (sexual != null && sexual > 6) return "감성적이면서도 선정적인 영화로 시작하셨네요.";
        else if (rating != null && rating > 8) return "작품성 높은 영화를 인상 깊게 보셨네요.";
        else return "차분하게 당신의 취향을 탐색하고 계시네요.";
    }
}