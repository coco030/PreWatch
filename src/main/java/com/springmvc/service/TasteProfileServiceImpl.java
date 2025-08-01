package com.springmvc.service;

import com.springmvc.domain.UserReviewScoreDTO; // 우리가 만든 DTO
import com.springmvc.repository.MemberRepository;
import com.springmvc.repository.StatRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class TasteProfileServiceImpl implements TasteProfileService {

    @Autowired
    private StatRepository statRepository;

    @Autowired
    private MemberRepository memberRepository;

    // 점수 타입과 한글 이름을 매핑. 확장을 위해 사용
    private static final Map<String, String> SCORE_TYPE_NAMES = Map.of(
            "violence", "액션/폭력성",
            "horror", "공포/스릴",
            "sexual", "감성/선정성"
    );

    @Override
    public void updateUserTasteProfile(String memberId) {
        // 1. Repository의 새 메소드를 호출하여 개인 리뷰 점수 리스트를 가져옴
        List<UserReviewScoreDTO> reviews = statRepository.findUserReviewScoresForAnalysis(memberId);
        
        // 유효한 리뷰(평점을 매긴 리뷰)만 필터링
        List<UserReviewScoreDTO> validReviews = reviews.stream()
            .filter(r -> r.getUserRating() != null)
            .collect(Collectors.toList());

        if (validReviews.isEmpty()) {
            memberRepository.updateTasteProfile(memberId, "취향 탐색 중", "아직 평가한 영화가 없네요. 첫 평가를 남겨주세요!", 0.0);
            return;
        }

        // 2. 각 지표별 '평균 점수' 계산 (사용자의 기본적인 선호도)
        Map<String, Double> averages = calculateAverages(validReviews);

        // 3. 각 지표별 '표준 편차' 계산 (취향의 일관성 vs 다양성)
        Map<String, Double> stdDevs = calculateStandardDeviations(validReviews, averages);

        // 4. 분석 결과로 타이틀과 리포트 생성
        String title = createTitle(averages, stdDevs);
        String report = createReport(averages, stdDevs);
        double anomalyScore = calculateAnomalyScore(averages, stdDevs);

        // 5. DB에 최종 결과 업데이트
        memberRepository.updateTasteProfile(memberId, title, report, anomalyScore);
    }
    
    // 마이페이지 시각화용 점수 제공
    @Override
    public Map<String, Double> getTasteScores(String memberId) {
        List<UserReviewScoreDTO> reviews = statRepository.findUserReviewScoresForAnalysis(memberId).stream()
            .filter(r -> r.getUserRating() != null).collect(Collectors.toList());
        return calculateAverages(reviews);
    }
    
    // --- 아래는 통계 계산을 위한 내부 도우미 메소드들 ---

    private Map<String, Double> calculateAverages(List<UserReviewScoreDTO> reviews) {
        Map<String, Double> averages = new HashMap<>();
        averages.put("rating", getAverage(reviews, UserReviewScoreDTO::getUserRating));
        averages.put("violence", getAverage(reviews, UserReviewScoreDTO::getViolenceScore));
        averages.put("horror", getAverage(reviews, UserReviewScoreDTO::getHorrorScore));
        averages.put("sexual", getAverage(reviews, UserReviewScoreDTO::getSexualScore));
        return averages;
    }

    private Map<String, Double> calculateStandardDeviations(List<UserReviewScoreDTO> reviews, Map<String, Double> averages) {
        Map<String, Double> stdDevs = new HashMap<>();
        stdDevs.put("violence", getStdDev(reviews, UserReviewScoreDTO::getViolenceScore, averages.get("violence")));
        stdDevs.put("horror", getStdDev(reviews, UserReviewScoreDTO::getHorrorScore, averages.get("horror")));
        stdDevs.put("sexual", getStdDev(reviews, UserReviewScoreDTO::getSexualScore, averages.get("sexual")));
        return stdDevs;
    }

    private String createTitle(Map<String, Double> averages, Map<String, Double> stdDevs) {
        double totalStdDev = stdDevs.values().stream().filter(Objects::nonNull).mapToDouble(Double::doubleValue).sum();
        String userType;
        if (totalStdDev > 7.5) userType = "탐험가";
        else if (totalStdDev < 3.5) userType = "수집가";
        else userType = "감식가";

        Optional<Map.Entry<String, Double>> coreEntry = averages.entrySet().stream()
                .filter(e -> !e.getKey().equals("rating") && e.getValue() != null)
                .max(Map.Entry.comparingByValue());

        String coreTaste = "드라마";
        if (coreEntry.isPresent() && coreEntry.get().getValue() > 5.5) {
            coreTaste = SCORE_TYPE_NAMES.get(coreEntry.get().getKey());
        } else if (averages.getOrDefault("rating", 0.0) > 7.5) {
            coreTaste = "작품성";
        }
        
        return String.format("%s를 즐기는 %s", coreTaste, userType);
    }
    
    private String createReport(Map<String, Double> averages, Map<String, Double> stdDevs) {
        StringBuilder report = new StringBuilder();
        report.append(String.format("당신은 평균적으로 작품성에 %.1f점, %s에 %.1f점, %s에 %.1f점, %s에 %.1f점을 주셨습니다. ",
                averages.getOrDefault("rating", 0.0),
                SCORE_TYPE_NAMES.get("violence"), averages.getOrDefault("violence", 0.0),
                SCORE_TYPE_NAMES.get("horror"), averages.getOrDefault("horror", 0.0),
                SCORE_TYPE_NAMES.get("sexual"), averages.getOrDefault("sexual", 0.0)
        ));
        
        double totalStdDev = stdDevs.values().stream().filter(Objects::nonNull).mapToDouble(Double::doubleValue).sum();
        if (totalStdDev > 7.5) {
            report.append("다양한 장르와 수위를 넘나들며 폭넓은 영화 경험을 추구하는 경향이 있습니다.");
        } else if (totalStdDev < 3.5) {
            report.append("자신만의 확고한 취향을 가지고 있으며, 좋아하는 분야를 깊이 파고드는 것을 즐깁니다.");
        } else {
            report.append("다양성과 깊이 사이에서 균형을 맞추며 안정적인 영화 감상을 하고 있습니다.");
        }
        return report.toString();
    }
    
    private double calculateAnomalyScore(Map<String, Double> averages, Map<String, Double> stdDevs) {
        double extremityScore = averages.values().stream().filter(Objects::nonNull)
                                    .mapToDouble(avg -> Math.abs(avg - 5.0)).sum();
        double diversityScore = stdDevs.values().stream().filter(Objects::nonNull).mapToDouble(Double::doubleValue).sum();
        return extremityScore + diversityScore;
    }

    private double getAverage(List<UserReviewScoreDTO> reviews, Function<UserReviewScoreDTO, Integer> extractor) {
        return reviews.stream().map(extractor).filter(Objects::nonNull)
                .mapToInt(Integer::intValue).average().orElse(0.0);
    }

    private double getStdDev(List<UserReviewScoreDTO> reviews, Function<UserReviewScoreDTO, Integer> extractor, double mean) {
        List<Integer> scores = reviews.stream().map(extractor).filter(Objects::nonNull).collect(Collectors.toList());
        if (scores.size() < 2) return 0.0;
        double variance = scores.stream().mapToDouble(score -> Math.pow(score - mean, 2)).sum() / scores.size();
        return Math.sqrt(variance);
    }
}