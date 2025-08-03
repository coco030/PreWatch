package com.springmvc.service;

import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.domain.TasteReportDTO;
import com.springmvc.domain.TasteReportDTO.*;
import com.springmvc.repository.ActorRepository;
import com.springmvc.repository.MemberRepository;
import com.springmvc.repository.StatRepository;
import com.springmvc.repository.UserReviewRepository;

@Service
public class TasteProfileServiceImpl implements TasteProfileService {

    @Autowired private StatRepository statRepository;
    @Autowired private UserReviewRepository userReviewRepository;
    @Autowired private MemberRepository memberRepository;
    @Autowired private StatService statService;
    @Autowired private ActorRepository actorRepository; 
    
    @Override
    public TasteReportDTO updateUserTasteProfile(String memberId) {
        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);
        
        if (reviewedMovies == null || reviewedMovies.size() < 5) {
            TasteReportDTO initialReport = new TasteReportDTO();
            initialReport.setInitialReport(true);
            initialReport.setTitle("취향 탐색 중...");
            initialReport.setInitialMessage("아직 평가가 부족해요. 5편 이상의 영화를 평가하면 당신만의 취향 리포트가 생성됩니다.");
            memberRepository.updateTasteProfile(memberId, initialReport.getTitle(), initialReport.getInitialMessage(), 0.0);
            return initialReport;
        }

        TasteReportDTO reportDTO = new TasteReportDTO();

        // 1. 핵심 분석 지표 계산
        Map<String, Double> deviationScores = statService.calculateUserDeviationScores(memberId);
        double consistencyScore = calculateConsistency(reviewedMovies);
        
        // 2. Repository에서 모든 추가 데이터 조회
        String signatureGenre = userReviewRepository.findSignatureGenre(memberId);
        Map<String, Object> mostReviewedActor = actorRepository.findMostFrequentActorForMember(memberId);
        Map<String, Object> highlyRatedActor = actorRepository.findHighlyRatedActorForMember(memberId);
        Map<String, Object> mostReviewedDirector = actorRepository.findMostFrequentDirectorForMember(memberId);
        Map<String, Object> highlyRatedDirector = actorRepository.findHighlyRatedDirectorForMember(memberId);
        String activityPattern = userReviewRepository.findActivityPattern(memberId);
        Map<String, Double> metaPreference = userReviewRepository.findMoviePreferenceMeta(memberId);
        List<String> topGenres = findTopGenres(reviewedMovies, 3);

        // 3. 조회된 데이터를 구조화된 DTO에 채우기
        FrequentPersons persons = reportDTO.getFrequentPersons();
        if (mostReviewedActor != null) {
            persons.setMostReviewedActor(new Person(
                (Long) mostReviewedActor.get("id"), 
                (String) mostReviewedActor.get("name"), 
                (String) mostReviewedActor.get("profile_image_url")
            ));
        }
        if (highlyRatedActor != null) {
            persons.setHighlyRatedActor(new Person(
                (Long) highlyRatedActor.get("id"), 
                (String) highlyRatedActor.get("name"), 
                (String) highlyRatedActor.get("profile_image_url")
            ));
        }
        if (mostReviewedDirector != null) {
            persons.setMostReviewedDirector(new Person(
                (Long) mostReviewedDirector.get("id"), 
                (String) mostReviewedDirector.get("name"), 
                (String) mostReviewedDirector.get("profile_image_url")
            ));
        }
        if (highlyRatedDirector != null) {
            persons.setHighlyRatedDirector(new Person(
                (Long) highlyRatedDirector.get("id"), 
                (String) highlyRatedDirector.get("name"), 
                (String) highlyRatedDirector.get("profile_image_url")
            ));
        }
        
        reportDTO.setTitle(createFinalTitle(signatureGenre, persons));
        
        reportDTO.getKeywords().setTopGenres(topGenres);
        reportDTO.getKeywords().setStyle(consistencyScore > 7.5 ? "#확고한편" : (consistencyScore < 4.0 ? "#다양한편" : "#밸런스형"));
        
        reportDTO.getAnalysis().setStrengths(getKeysByCondition(deviationScores, score -> score > 1.0));
        reportDTO.getAnalysis().setWeaknesses(getKeysByCondition(deviationScores, score -> score < -1.0));
        reportDTO.getAnalysis().setSpecialInsight(findSpecialInsight(deviationScores));

        if (metaPreference != null) {
            reportDTO.getPreferences().setPreferredYear(formatYear(metaPreference.get("avgYear")));
            reportDTO.getPreferences().setPreferredRuntime(formatRuntime(metaPreference.get("avgRuntime")));
        }
        
        reportDTO.setActivityPattern(activityPattern != null ? String.format("%s에 주로 활동", activityPattern) : null);
        
        createRecommendation(reportDTO);
        
        // 4. DB에 일부 정보 업데이트
        memberRepository.updateTasteProfile(memberId, reportDTO.getTitle(), "상세 리포트가 생성되었습니다. 마이페이지에서 확인하세요.", 0.0);

        return reportDTO;
    }

    @Override
    public Map<String, Double> getTasteScores(String memberId) {
        return statService.calculateUserDeviationScores(memberId);
    }
    
    // --- 헬퍼 메소드들 ---

    private String createFinalTitle(String signatureGenre, FrequentPersons persons) {
        if (persons.getHighlyRatedDirector() != null && signatureGenre != null) {
            return String.format("%s 감독의 작품에 높은 만족도를 보인, %s 전문가", persons.getHighlyRatedDirector().getName(), signatureGenre);
        } else if (persons.getMostReviewedDirector() != null && signatureGenre != null) {
            return String.format("%s 감독의 작품을 꾸준히 감상해 온, %s 애호가", persons.getMostReviewedDirector().getName(), signatureGenre);
        } else if (signatureGenre != null) {
            return String.format("%s 장르의 확고한 지지자", signatureGenre);
        }
        return "다채로운 취향의 소유자";
    }

    private void createRecommendation(TasteReportDTO reportDTO) {
        Recommendation rec = reportDTO.getRecommendation();
        List<String> topGenres = reportDTO.getKeywords().getTopGenres();
        List<String> strengths = reportDTO.getAnalysis().getStrengths();
        List<String> weaknesses = reportDTO.getAnalysis().getWeaknesses();
        
        if (topGenres.isEmpty()) {
            rec.setSafeBet("다양한 장르의 명작들을 감상하며 당신의 대표 장르를 찾아보세요.");
            rec.setAdventurousChoice("평점이 높은 영화부터 시작하는 것이 좋은 방법입니다.");
            return;
        }
        String topGenre = topGenres.get(0);
        
        if (!strengths.isEmpty()) {
            rec.setSafeBet(String.format("<strong>%s</strong> 장르 중 <strong>%s</strong>이(가) 돋보이는 작품은 당신에게 최고의 만족을 줄 것입니다.", topGenre, strengths.get(0)));
        } else {
            rec.setSafeBet(String.format("<strong>%s</strong> 장르의 인기작들을 감상하며 당신의 다음 '강점'을 발견해보세요.", topGenre));
        }

        if (!weaknesses.isEmpty()) {
            rec.setAdventurousChoice(String.format("당신이 민감한 '<strong>%s</strong>' 요소가 없는, 순수한 <strong>드라마</strong>나 <strong>코미디</strong> 장르는 어떠신가요?", weaknesses.get(0)));
        } else if (topGenres.size() > 1) {
            rec.setAdventurousChoice(String.format("당신의 또 다른 관심 장르인 <strong>%s</strong>에 도전하여 취향의 지도를 넓혀보세요.", topGenres.get(1)));
        } else {
            rec.setAdventurousChoice("지금까지와는 다른 새로운 장르의 대표작을 감상하며 신선한 자극을 느껴보는 것을 추천합니다.");
        }
    }

    private List<String> getKeysByCondition(Map<String, Double> map, java.util.function.Predicate<Double> condition) {
        return map.entrySet().stream().filter(entry -> condition.test(entry.getValue())).map(Map.Entry::getKey).sorted().collect(Collectors.toList());
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
        if (runtime >= 140) return "140분 이상의 긴 호흡의 영화";
        if (runtime >= 110) return "110~140분 사이 표준 길이의 영화";
        return "110분 미만의 짧고 강렬한 영화";
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
        return genreCounts.entrySet().stream().sorted(Map.Entry.<String, Integer>comparingByValue().reversed()).limit(limit).map(Map.Entry::getKey).collect(Collectors.toList());
    }

    private double calculateConsistency(List<TasteAnalysisDataDTO> reviewedMovies) {
        if (reviewedMovies.size() < 2) return 5.0;
        List<Integer> myRatings = reviewedMovies.stream().map(TasteAnalysisDataDTO::getMyUserRating).filter(r -> r != null).collect(Collectors.toList());
        double mean = myRatings.stream().mapToInt(Integer::intValue).average().orElse(0.0);
        double stdDev = Math.sqrt(myRatings.stream().mapToDouble(r -> Math.pow(r - mean, 2)).average().orElse(0.0));
        return Math.max(0, 10 - (stdDev * 3.33));
    }

    private String findSpecialInsight(Map<String, Double> deviationScores) {
        boolean lovesThriller = deviationScores.getOrDefault("스릴", 0.0) > 1.0;
        boolean hatesViolence = deviationScores.getOrDefault("액션", 0.0) < -1.0;
        boolean lovesAction = deviationScores.getOrDefault("액션", 0.0) > 1.0;
        boolean lovesRomance = deviationScores.getOrDefault("감성", 0.0) > 1.0;
        if (lovesThriller && hatesViolence) return "잔인한 장면 없이 심리적으로 옥죄는 스릴러에 깊이 매료되는, 고도의 집중력을 가진 감상가입니다.";
        if (lovesAction && lovesRomance) return "화려한 액션 속에서 피어나는 주인공들의 애틋한 감정선에 유독 깊게 몰입하는 특별한 감수성을 지니셨네요.";
        return null;
    }
}