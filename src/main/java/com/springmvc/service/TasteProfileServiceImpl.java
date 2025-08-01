package com.springmvc.service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    
    @Override
    public void updateUserTasteProfile(String memberId) {
        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);
        if (reviewedMovies.isEmpty()) {
            memberRepository.updateTasteProfile(memberId, "취향 탐색 중", "아직 평가한 영화가 없네요. 첫 평가를 남겨 당신의 취향을 알려주세요!", 0.0);
            return;
        }

        // 평균 계산
        double ratingAvg = calculateWeightedAverage(reviewedMovies, "rating");
        double violenceAvg = calculateWeightedAverage(reviewedMovies, "violence");
        double horrorAvg = calculateWeightedAverage(reviewedMovies, "horror");
        double sexualAvg = calculateWeightedAverage(reviewedMovies, "sexual");

        double violenceStdDev = calculateWeightedStandardDeviation(reviewedMovies, "violence", violenceAvg);
        double horrorStdDev = calculateWeightedStandardDeviation(reviewedMovies, "horror", horrorAvg);
        double sexualStdDev = calculateWeightedStandardDeviation(reviewedMovies, "sexual", sexualAvg);

        double anomalyScore = calculateInternalAnomalyScore(
            ratingAvg, violenceAvg, horrorAvg, sexualAvg,
            violenceStdDev, horrorStdDev, sexualStdDev
        );

        String keywordAlias = createKeywordAlias(
            ratingAvg, violenceAvg, horrorAvg, sexualAvg,
            violenceStdDev, horrorStdDev, sexualStdDev
        );

        String finalTitle = "";
        String finalReport = "";

        if (reviewedMovies.size() < 5) {
            finalTitle = "취향을 알아가는 중인 감상가";
            String base = "정확한 결과를 위해 당신의 취향을 파악 중입니다. 더 많은 평가를 남겨 주세요.";
            String encouragement = createInitialComment(reviewedMovies);
            finalReport = encouragement + " " + base;
        } else {
            finalTitle = createFinalTitle(keywordAlias, anomalyScore);
            finalReport = createFinalReport(keywordAlias, anomalyScore);
        }

        memberRepository.updateTasteProfile(memberId, finalTitle, finalReport, anomalyScore);
    }


    @Override
    public Map<String, Double> getTasteScores(String memberId) {
        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);
        
        if (reviewedMovies.isEmpty()) {
            return Collections.emptyMap();
        }

        Map<String, Double> scores = new HashMap<>();
        scores.put("작품성", calculateWeightedAverage(reviewedMovies, "rating"));
        scores.put("액션", calculateWeightedAverage(reviewedMovies, "violence"));
        scores.put("스릴", calculateWeightedAverage(reviewedMovies, "horror"));
        scores.put("감성", calculateWeightedAverage(reviewedMovies, "sexual"));
        return scores;
    }
    
    // --- 이하 모든 헬퍼(private) 메소드들은 수정 없이 그대로 유지 ---
    private double calculateWeightedAverage(List<TasteAnalysisDataDTO> reviewedMovies, String scoreType) {
        double weightedSum = 0.0;
        double totalWeight = 0.0;
        for (TasteAnalysisDataDTO movie : reviewedMovies) {
            Double movieScore = getScoreByType(movie, scoreType);
            Integer myRating = movie.getMyUserRating();
            if (movieScore == null || myRating == null) continue;
            double myRatingWeight = myRating / 10.0;
            weightedSum += movieScore * myRatingWeight;
            totalWeight += myRatingWeight;
        }
        return (totalWeight > 0) ? (weightedSum / totalWeight) : 0.0;
    }

    private double calculateWeightedStandardDeviation(List<TasteAnalysisDataDTO> reviewedMovies, String scoreType, double weightedMean) {
        double weightedVarianceSum = 0.0;
        double totalWeight = 0.0;
        for (TasteAnalysisDataDTO movie : reviewedMovies) {
            Double movieScore = getScoreByType(movie, scoreType);
            Integer myRating = movie.getMyUserRating();
            if (movieScore == null || myRating == null) continue;
            double myRatingWeight = myRating / 10.0;
            weightedVarianceSum += myRatingWeight * Math.pow(movieScore - weightedMean, 2);
            totalWeight += myRatingWeight;
        }
        return (totalWeight > 0) ? Math.sqrt(weightedVarianceSum / totalWeight) : 0.0;
    }
    
    private Double getScoreByType(TasteAnalysisDataDTO movie, String scoreType) {
        switch (scoreType) {
            case "rating":   return movie.getMovieAvgRating();
            case "violence": return movie.getMovieAvgViolence();
            case "horror":   return movie.getMovieAvgHorror();
            case "sexual":   return movie.getMovieAvgSexual();
            default:         return 0.0;
        }
    }
    
    private double calculateInternalAnomalyScore(double rAvg, double vAvg, double hAvg, double sAvg,
                                                   double vStd, double hStd, double sStd) {
        double extremity = Math.abs(rAvg - 5.0) + Math.abs(vAvg - 5.0) + Math.abs(hAvg - 5.0) + Math.abs(sAvg - 5.0);
        double diversity = vStd + hStd + sStd;
        return extremity + diversity;
    }

    private String createKeywordAlias(double rating, double violence, double horror, double sexual,
            double stdDevV, double stdDevH, double stdDevS) {
			Map<String, Double> coreTastes = Map.of("작품성", rating, "액션", violence, "스릴", horror, "감성", sexual);
			String coreTaste = coreTastes.entrySet().stream()
			       .max(Map.Entry.comparingByValue())
			       .map(Map.Entry::getKey)
			       .orElse("드라마");
			String userType = "애호가";
			double totalStdDev = stdDevV + stdDevH + stdDevS;
			if (totalStdDev > 7.0) userType = "탐험가";
			else if (totalStdDev < 3.0) userType = "수집가";
			else if (rating > 7.5) userType = "감식가";
			String modifier = "균형잡힌";
			if (rating > 8.0) modifier = "확고한 작품성의";
			else if (violence > 6.0 && sexual < 3.0) modifier = "절제된 카타르시스의";
			else if (totalStdDev > 7.0) modifier = "경계를 넘나드는";
			
			// coreTaste가 '작품성'이면, '작품성의'로 시작하지 않도록 수정
			if ("작품성".equals(coreTaste)) {
			return modifier + " " + userType;
			} else {
			return modifier + " " + coreTaste + " " + userType;
			}
}


    private String createFinalTitle(String keywordAlias, double anomalyScore) {
        String rarityModifier = "균형잡힌 시각의";
        if (anomalyScore > 20) rarityModifier = "극소수만이 공유하는";
        else if (anomalyScore > 15) rarityModifier = "희소성 있는 취향의";
        else if (anomalyScore > 10) rarityModifier = "뚜렷한 개성을 지닌";
        return rarityModifier + " " + keywordAlias;
    }
    
    private String createFinalReport(String keywordAlias, double anomalyScore) {
        String rarityDescription;
        if (anomalyScore > 20) {
            rarityDescription = "당신의 취향은 매우 뚜렷한 개성을 가지고 있어, 다른 사람들과는 확연히 구분되는 자신만의 영화 세계를 구축하셨습니다.";
        } else if (anomalyScore > 10) {
            rarityDescription = "선호하는 장르와 스타일에 대한 자신만의 기준이 명확하여, 꾸준히 만족스러운 영화적 경험을 쌓아가고 있습니다.";
        } else {
            rarityDescription = "다양한 장르와 스타일에 열려 있어, 폭넓은 영화 세계를 편견 없이 즐기는 경향이 있습니다.";
        }
        return String.format("당신은 '%s'입니다. %s", keywordAlias, rarityDescription);
    }

    private String createInitialComment(List<TasteAnalysisDataDTO> reviewedMovies) {
        int size = reviewedMovies.size();
        String stageMessage = "";
        switch (size) {
            case 1:
                stageMessage = "첫 평가를 남기셨어요.";
                break;
            case 2:
                stageMessage = "두 번째 평가도 완료!";
                break;
            case 3:
                stageMessage = "세 번째 영화까지 평가 완료!";
                break;
            case 4:
                stageMessage = "네 편의 영화에서 취향의 힌트가 보이기 시작했어요.";
                break;
            default:
                return "";
        }

        // 마지막 평가한 영화 기준으로 인상 포인트 도출
        TasteAnalysisDataDTO latestReview = reviewedMovies.get(reviewedMovies.size() - 1);
        String firstImpression = createFirstImpression(latestReview);

        return stageMessage + firstImpression;
    }
    
    private String createFirstImpression(TasteAnalysisDataDTO latestReview) {
        Integer violence = latestReview.getMyViolenceScore();
        Integer horror = latestReview.getMyHorrorScore();
        Integer sexual = latestReview.getMySexualScore();
        Integer rating = latestReview.getMyUserRating();

        if (violence != null && violence > 6) {
            return " 강렬한 액션으로 영화 여정을 시작하셨군요.";
        } else if (horror != null && horror > 6) {
            return " 짜릿한 스릴과 함께 당신의 취향을 찾아가고 있네요.";
        } else if (sexual != null && sexual > 6) {
            return " 감성적이면서도 선정적인 영화로 시작하셨네요.";
        } else if (rating != null && rating > 8) {
            return " 작품성 높은 영화를 인상 깊게 보셨네요.";
        } else {
            return "";
        }
    }

}