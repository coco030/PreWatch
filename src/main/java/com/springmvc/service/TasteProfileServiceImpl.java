package com.springmvc.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry; 
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.domain.TasteReportDTO;
import com.springmvc.domain.TasteReportDTO.FrequentPersons;
import com.springmvc.domain.TasteReportDTO.Person;
import com.springmvc.domain.TasteReportDTO.PotentialDesire;
import com.springmvc.domain.TasteReportDTO.Recommendation;
import com.springmvc.repository.ActorRepository;
import com.springmvc.repository.MemberRepository;
import com.springmvc.repository.StatRepository;
import com.springmvc.repository.UserReviewRepository;
import com.springmvc.repository.userCartRepository; 

@Service
public class TasteProfileServiceImpl implements TasteProfileService {

    @Autowired private StatRepository statRepository;
    @Autowired private UserReviewRepository userReviewRepository;
    @Autowired private MemberRepository memberRepository;
    @Autowired private StatService statService;
    @Autowired private ActorRepository actorRepository; 
    @Autowired private userCartRepository userCartRepository; 

    @Override
    public TasteReportDTO updateUserTasteProfile(String memberId) {
        List<TasteAnalysisDataDTO> reviewedMoviesData = statRepository.findTasteAnalysisData(memberId);
        
        
        if (reviewedMoviesData == null || reviewedMoviesData.size() < 5) {
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
        double consistencyScore = calculateConsistency(reviewedMoviesData);
        
        // 2. Repository에서 모든 추가 데이터 조회
        String signatureGenre = userReviewRepository.findSignatureGenre(memberId);
        Map<String, Object> mostReviewedActor = actorRepository.findMostFrequentActorForMember(memberId);
        Map<String, Object> highlyRatedActor = actorRepository.findHighlyRatedActorForMember(memberId);
        Map<String, Object> mostReviewedDirector = actorRepository.findMostFrequentDirectorForMember(memberId);
        Map<String, Object> highlyRatedDirector = actorRepository.findHighlyRatedDirectorForMember(memberId);
        String activityPattern = userReviewRepository.findActivityPattern(memberId);
        Map<String, Double> metaPreference = userReviewRepository.findMoviePreferenceMeta(memberId);
        List<String> topGenres = findTopGenres(reviewedMoviesData, 3);
      
        // 3. 잠재 욕망 분석 (새로운 로직)
        PotentialDesire desire = analyzePotentialDesire(memberId);
        if (desire != null) {
            reportDTO.setPotentialDesire(desire);
        }

        // 4. 조회된 데이터를 구조화된 DTO에 채우기
        FrequentPersons persons = reportDTO.getFrequentPersons();
        if (mostReviewedActor != null) { persons.setMostReviewedActor(new Person((Long) mostReviewedActor.get("id"), (String) mostReviewedActor.get("name"), (String) mostReviewedActor.get("profile_image_url"))); }
        if (highlyRatedActor != null) { persons.setHighlyRatedActor(new Person((Long) highlyRatedActor.get("id"), (String) highlyRatedActor.get("name"), (String) highlyRatedActor.get("profile_image_url"))); }
        if (mostReviewedDirector != null) { persons.setMostReviewedDirector(new Person((Long) mostReviewedDirector.get("id"), (String) mostReviewedDirector.get("name"), (String) mostReviewedDirector.get("profile_image_url"))); }
        if (highlyRatedDirector != null) { persons.setHighlyRatedDirector(new Person((Long) highlyRatedDirector.get("id"), (String) highlyRatedDirector.get("name"), (String) highlyRatedDirector.get("profile_image_url"))); }
        
        reportDTO.setTitle(createFinalTitle(signatureGenre, persons));
        reportDTO.getKeywords().setTopGenres(topGenres);
        Map<String, String> styleAnalysis = analyzeUserStyle(consistencyScore, deviationScores, topGenres);
        reportDTO.getKeywords().setStyle(styleAnalysis.get("style"));
        reportDTO.setStyleDescription(styleAnalysis.get("description")); 
        reportDTO.getAnalysis().setStrengths(getKeysByCondition(deviationScores, score -> score > 1.0));
        reportDTO.getAnalysis().setWeaknesses(getKeysByCondition(deviationScores, score -> score < -1.0));
        reportDTO.getAnalysis().setSpecialInsight(findSpecialInsight(deviationScores));
        if (metaPreference != null) {
            reportDTO.getPreferences().setPreferredYear(formatYear(metaPreference.get("avgYear")));
            reportDTO.getPreferences().setPreferredRuntime(formatRuntime(metaPreference.get("avgRuntime")));
        }
        reportDTO.setActivityPattern(activityPattern != null ? String.format("%s에 주로 활동", activityPattern) : null);
        
        createRecommendation(reportDTO, deviationScores);
        
        // 5. DB에 일부 정보 업데이트
        memberRepository.updateTasteProfile(memberId, reportDTO.getTitle(), reportDTO.getKeywords().getStyle(), 0.0);
        return reportDTO;
    }


   
    //심즈체로 구현한 찜과 관련된 메서드

	private PotentialDesire analyzePotentialDesire(String memberId) {
        // STEP 1: 데이터 준비
        List<Long> reviewedMovieIds = userReviewRepository.findMovieIdsByMemberId(memberId);
        List<Long> cartMovieIds = userCartRepository.findMovieIdsInCartByMemberId(memberId);

        if (cartMovieIds.isEmpty() || reviewedMovieIds.isEmpty()) {
            return null;
        }
        
        List<PotentialDesire> foundDesires = new ArrayList<PotentialDesire>();

        // [사전 계산]
        double avgReviewedRating = statRepository.findAverageRatingByMovieIds(reviewedMovieIds);
        double avgReviewedRuntime = statRepository.findAverageRuntimeByMovieIds(reviewedMovieIds);
        double avgCartRuntime = statRepository.findAverageRuntimeByMovieIds(cartMovieIds);

        // 시나리오: '망작' 탐험가 (중요도: 7)
        double lowRatedCount = 0;
        Map<Long, Double> cartMovieRatings = statRepository.findRatingsByMovieIds(cartMovieIds);
        for (Double rating : cartMovieRatings.values()) {
            if (rating != null && rating <= 4.5) { lowRatedCount++; }
        }
        if (avgReviewedRating >= 6.5 && lowRatedCount / cartMovieIds.size() >= 0.3) {
            foundDesires.add(new PotentialDesire("[특이 행동 감지: 실패 경험 수집]", "성공적인 영화 경험만으로는 만족할 수 없는 단계에 도달했습니다. 당신의 호기심은 이제 '실패는 어떤 맛일까?'로 향하고 있습니다. 부작용은 책임지지 않습니다.", 7));
        }
        
        // 시나리오: 특정 감독 '꽂힘' (중요도: 10)
        Map<String, Long> directorCountsInCart = statRepository.findDirectorCountsByMovieIds(cartMovieIds);
        for (Entry<String, Long> entry : directorCountsInCart.entrySet()) {
            if (entry.getValue() >= 3 || (double)entry.getValue() / cartMovieIds.size() >= 0.3) {
                foundDesires.add(new PotentialDesire("[새 목표 설정: " + entry.getKey() + " 따라가기]", "마음에 드는 창조주 '" + entry.getKey() + "' 감독을 발견한 것 같습니다. 찜 목록이 그의 세계관으로 채워지고 있습니다.", 10));
                break;
            }
        }
        
        // 시나리오: 특정 '마이너 장르' 탐험 (중요도: 9)
        Map<Long, List<String>> reviewedGenresMap = statRepository.findGenresByMovieIds(reviewedMovieIds);
        Map<String, Long> reviewedGenreCounts = new HashMap<String, Long>();
        for(List<String> genres : reviewedGenresMap.values()) { for(String genre : genres) { reviewedGenreCounts.put(genre, reviewedGenreCounts.getOrDefault(genre, 0L) + 1); } }
        Map<Long, List<String>> cartGenresMap = statRepository.findGenresByMovieIds(cartMovieIds);
        Map<String, Long> cartGenreCounts = new HashMap<String, Long>();
        for(List<String> genres : cartGenresMap.values()) { for(String genre : genres) { cartGenreCounts.put(genre, cartGenreCounts.getOrDefault(genre, 0L) + 1); } }
        
        if (cartGenreCounts.getOrDefault("Animation", 0L) >= 2 && reviewedGenreCounts.getOrDefault("Animation", 0L) <= 1) {
            foundDesires.add(new PotentialDesire("[알림: 2D 세계로의 동경 감지]", "실사 영화의 세계를 지나, 이제 현실의 물리법칙을 벗어나고 싶다는 신호를 보내고 있습니다.", 9));
        }
        if (cartGenreCounts.getOrDefault("Documentary", 0L) >= 2 && reviewedGenreCounts.getOrDefault("Documentary", 0L) == 0) {
            foundDesires.add(new PotentialDesire("[시스템 메시지: '진실' 탐구 욕구 발견]", "허구의 세계에서 충분한 경험치를 쌓았습니다. 이제 당신의 뇌는 '사실'에 기반한 데이터 입력을 요구하고 있습니다.", 9));
        }

        // 시나리오: '호불호 갈리는' 영화 도전 (중요도: 7)
        double divisiveMovieCount = 0;
        for (Double rating : cartMovieRatings.values()) {
            // 6.5점 미만이면서 4.5점 초과인 영화를 '호불호' 영화로 간주
            if (rating != null && rating < 6.5 && rating > 4.5) {
                divisiveMovieCount++;
            }
        }
        if (divisiveMovieCount / cartMovieIds.size() >= 0.4) { // 찜 목록의 40% 이상이 호불호 영화일 때
            foundDesires.add(new PotentialDesire("[지적 허영심 스탯 활성화]", "안전하고 검증된 선택에서 벗어나, 이제 당신은 남들이 쉽게 판단하지 못하는 영화에 도전하고 싶어 하는군요. 좋습니다. 당신의 비평가적 안목을 시험해보세요.", 7));
        }

        // ✨ [신규 추가] 시나리오: 배우 세대교체 (중요도: 6)
        double avgReviewedActorBirthYear = statRepository.findAverageActorBirthYearByMovieIds(reviewedMovieIds);
        double avgCartActorBirthYear = statRepository.findAverageActorBirthYearByMovieIds(cartMovieIds);
        if (avgReviewedActorBirthYear > 0 && avgCartActorBirthYear > 0 && Math.abs(avgReviewedActorBirthYear - avgCartActorBirthYear) >= 10) {
            if (avgCartActorBirthYear > avgReviewedActorBirthYear) {
                foundDesires.add(new PotentialDesire("[상호작용 대상 업데이트: 신세대]", "익숙한 얼굴들과의 관계에서 벗어나, 새로운 세대의 배우들에게 눈을 돌리고 있습니다. 당신의 '인맥'이 더 젊고 트렌디해질 것입니다.", 6));
            } else {
                foundDesires.add(new PotentialDesire("[상호작용 대상 업데이트: 레전드]", "최신 유행을 따르기보다, 시대를 초월한 연기를 선보이는 전설적인 배우들의 작품을 탐험하고 싶어 하는군요. 과거로의 시간여행을 준비하세요.", 6));
            }
        }
        
        // 시나리오: 러닝타임 변화 (중요도: 8)
        if (avgReviewedRuntime > 0 && avgCartRuntime > 0 && Math.abs(avgReviewedRuntime - avgCartRuntime) >= 20) {
            if (avgCartRuntime < avgReviewedRuntime) {
                foundDesires.add(new PotentialDesire("[에너지 관리 모드 변경: 단거리]", "장시간 영화에서 벗어나, 짧고 강렬한 영화를 찾고 있군요. 빠른 에너지 충전을 원합니다.", 8));
            } else {
                foundDesires.add(new PotentialDesire("[에너지 관리 모드 변경: 장거리]", "짧은 영화들을 지나, 이제는 긴 호흡으로 깊이 몰입할 수 있는 대서사를 갈망하고 있습니다.", 8));
            }
        }

        // STEP 3: 수집된 결과 처리
        if (foundDesires.isEmpty()) {
            return new PotentialDesire("[분석 완료: 확고한 취향의 소유자]", "당신의 감상 기록과 욕망 목록은 거의 완벽하게 일치합니다. 한눈을 파는 법이 없군요. 당신은 무엇을 원하는지 정확히 알고 있습니다.", 1);
        } else {
            Collections.sort(foundDesires, new Comparator<PotentialDesire>() {
                @Override
                public int compare(PotentialDesire o1, PotentialDesire o2) {
                    return Integer.compare(o2.getPriority(), o1.getPriority());
                }
            });

         // 최대 2개의 메시지를 조합하여 최종 결과 생성
            if (foundDesires.size() >= 2) {
                PotentialDesire first = foundDesires.get(0);
                PotentialDesire second = foundDesires.get(1);
                // 제목은 JSP에서 고정, 메시지만 조합
                String combinedMessage = first.getMessage() + "<br><br>" + "뿐만 아니라, " + second.getMessage().toLowerCase();
                // 제목 필드는 간단하게, 메시지만 조합하여 전달
                return new PotentialDesire("Potential Desire", combinedMessage, first.getPriority());
            } else {
                // 1개만 발견된 경우, 제목은 간단하게, 메시지만 전달
                PotentialDesire singleDesire = foundDesires.get(0);
                return new PotentialDesire("Potential Desire", singleDesire.getMessage(), singleDesire.getPriority());
            }
        }
    }
        
	private String createFinalTitle(String signatureGenre, FrequentPersons persons) {
	    // 1순위: 특정 감독에게 높은 만족도를 보임
	    if (persons.getHighlyRatedDirector() != null && signatureGenre != null) {
	        return String.format("%s 감독의 작품과 %s 장르에 대한 깊은 이해를 보여주는 당신", persons.getHighlyRatedDirector().getName(), signatureGenre);
	    }
	    // 2순위: 특정 감독의 작품을 꾸준히 감상함
	    if (persons.getMostReviewedDirector() != null && signatureGenre != null) {
	        return String.format("%s 감독의 작품과 %s 장르에 꾸준한 애정을 보여주는 당신", persons.getMostReviewedDirector().getName(), signatureGenre);
	    }
	    // 3순위: 뚜렷한 대표 장르가 있음
	    if (signatureGenre != null) {
	        return String.format("%s 장르에 대한 확고한 취향을 가진 당신", signatureGenre);
	    }
	    // 4순위: 위 모든 특징이 없음 (기본값)
	    return "다채로운 스펙트럼을 가진 당신";
	}


	private void createRecommendation(TasteReportDTO reportDTO, Map<String, Double> deviationScores) { // <-- 파라미터 추가
	    Recommendation rec = reportDTO.getRecommendation();
	    List<String> topGenres = reportDTO.getKeywords().getTopGenres();
	    // 이제 DTO에서 가져오는 대신, 파라미터로 받은 deviationScores를 직접 사용합니다.
	    
	    // 만족도 편차
	    double qualityPref = deviationScores.getOrDefault("작품성", 0.0);
	    
	    if (topGenres.isEmpty()) {
	        rec.setSafeBet("다양한 장르의 명작들을 감상하며 당신의 대표 장르를 찾아보세요.");
	        rec.setAdventurousChoice("평점이 높은 영화부터 시작하는 것이 좋은 방법입니다.");
	        return;
	    }
	    String topGenre = topGenres.get(0);
	 
	 // [안전한 추천]: 나의 '성공 공식'에 기반한 추천
	    if (qualityPref > 1.0) {
	        rec.setSafeBet(String.format("당신은 대중의 평가를 넘어 자신만의 보석을 찾아내는 안목을 가졌습니다. <strong>%s</strong> 장르의 숨겨진 명작들이나, 평론가들의 극찬을 받은 작품들이 좋은 선택이 될 겁니다.", topGenre));
	    } else {
	        rec.setSafeBet(String.format("안정적인 재미를 추구하는 당신에게, <strong>%s</strong> 장르에서 대중적으로 가장 높은 평가를 받은 영화는 이번에도 만족스러운 경험을 선사할 것입니다.", topGenre));
	    }

	    // [모험적인 추천]: 나의 '대표 장르'가 아닌 다른 장르 추천
	    String adventurousGenre = findOppositeGenre(topGenre);
	    rec.setAdventurousChoice(String.format("가끔은 익숙한 <strong>%s</strong> 장르에서 벗어나, 정반대의 매력을 가진 <strong>%s</strong> 장르의 대표작을 감상하며 새로운 자극을 느껴보는 것은 어떨까요?", topGenre, adventurousGenre));
	}

	// createRecommendation을 위한 헬퍼 메서드 추가 (이건 그대로 두시면 됩니다)
	private String findOppositeGenre(String genre) {
	    if (List.of("Action", "War", "Crime").contains(genre)) return "Romance";
	    if (List.of("Romance", "Drama", "Family").contains(genre)) return "Thriller";
	    if (List.of("Horror", "Thriller").contains(genre)) return "Comedy";
	    if (List.of("Comedy", "Musical").contains(genre)) return "Documentary";
	    return "Fantasy";
	}

    private List<String> getKeysByCondition(Map<String, Double> map, java.util.function.Predicate<Double> condition) {
        return map.entrySet().stream().filter(entry -> condition.test(entry.getValue())).map(Map.Entry::getKey).sorted().collect(Collectors.toList());
    }
    
    private String formatYear(Double avgYear) {
        if (avgYear == null || avgYear == 0) return null;
        int year = avgYear.intValue();

        if (year >= 2025) return "최근 개봉한 영화들을 자주 감상하는 편이에요.";
        if (year == 2024) return "2024년 개봉작이 중심이 된 감상 경향입니다.";
        if (year == 2023) return "2023년 개봉작들을 비교적 자주 본 것으로 보여요.";
        if (year >= 2020) return "2020년대 초반의 영화에 익숙한 취향이에요.";
        if (year >= 2010) return "최근 10~15년 사이의 작품들을 많이 감상했네요.";
        if (year >= 2000) return "2000년대 영화에 가까운 감상 흐름을 가지고 있어요.";
        if (year >= 1990) return "90년대 영화에 친숙한 감상 패턴이 나타납니다.";
        if (year >= 1980) return "1980년대 영화들을 자주 접한 것으로 보입니다.";
        if (year >= 1970) return "1970년대 영화에 대한 선호가 엿보여요.";
        if (year >= 1950) return "1950~60년대 영화 감상이 비교적 많은 편이에요.";
        return "고전 영화에 대한 깊은 관심이 느껴지는 감상 경향입니다.";
    }

    private String formatRuntime(Double avgRuntime) {
        if (avgRuntime == null || avgRuntime == 0) return null;
        int runtime = avgRuntime.intValue();

        if (runtime >= 180) return "3시간이 넘는 대작 영화에도 끌림을 느끼는 편입니다.";
        if (runtime >= 150) return "2시간 반 이상의 긴 영화에도 충분히 집중하는 경향이 있습니다.";
        if (runtime >= 130) return "2시간을 훌쩍 넘는 러닝타임의 영화에 익숙한 감상 패턴을 보입니다.";
        if (runtime >= 110) return "2시간 안팎의 표준 길이 영화를 안정적으로 감상하는 경향이 있습니다.";
        if (runtime >= 90)  return "1시간 반 정도의 부담 없는 길이의 영화에 편안함을 느끼는 편입니다.";
        if (runtime >= 70)  return "1시간 내외의 짧은 영화에 집중하는 경향이 있습니다.";
        if (runtime >= 40)  return "중편 영화나 TV 특집 영화와 같은 비교적 짧은 러닝타임에 익숙한 감상입니다.";
        if (runtime >= 20)  return "단편 영화에 가까운 짧은 러닝타임의 작품을 선호하는 경향이 있습니다.";
        if (runtime >= 10)  return "10분대의 초단편 영화에 주로 관심을 두는 편입니다.";
        return "10분 미만의 실험적 영상이나 초단편 영화에 관심을 갖고 있는 것으로 보입니다.";
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
        // '감성'(=선정성)을 좋아하는지 확인
        boolean lovesProvocativeness = deviationScores.getOrDefault("감성", 0.0) > 1.0;
        boolean lovesArt = deviationScores.getOrDefault("작품성", 0.0) > 1.0;
        // '스릴'을 싫어하는지 확인
        boolean hatesThrill = deviationScores.getOrDefault("스릴", 0.0) < -1.0;

        if (lovesThriller && hatesViolence)
            return "잔인한 장면 없이 심리적으로 옥죄는 스릴러에 깊이 몰입하는 경향이 있습니다.";
        if (lovesAction && lovesProvocativeness) // lovesRomance -> lovesProvocativeness 로 의미 명확화
            return "화려한 액션 속에서도 인물 간 자극적인 관계나 감정선에 주목하는 스타일이 돋보입니다.";
        if (lovesProvocativeness && lovesArt) // lovesEmotion -> lovesProvocativeness 로 의미 명확화
            return "감정의 흐름과 작품성 모두에 민감하게 반응하는 섬세한 감상 성향입니다.";
        if (lovesArt && hatesThrill)
            return "긴장감보다는 구조와 메시지에 집중하는 차분한 감상을 선호합니다.";
        
        // "공포"를 "스릴"로 수정
        if (lovesProvocativeness && hatesThrill) // hatesHorror -> hatesThrill
            return "감성(선정성) 중심 영화는 좋아하지만, 긴장감 넘치는 스릴러 요소는 기피하는 편입니다.";

        // 단일 강한 편차도 커버 가능
        if (deviationScores.getOrDefault("스릴", 0.0) > 1.5) // "공포" -> "스릴"
            return "스릴러/공포 장르에 대한 뚜렷한 선호가 감상 경향에 드러납니다.";
        if (deviationScores.getOrDefault("작품성", 0.0) < -1.5)
            return "작품의 완성도보다는 즉각적인 재미를 더 중시하는 경향이 있습니다.";

        return null;
    }
    
    @Override
    public Map<String, Double> getTasteScores(String memberId) {
        return statService.calculateUserDeviationScores(memberId);
    }
    
    private Map<String, String> analyzeUserStyle(double consistency, Map<String, Double> deviation, List<String> topGenres) {
        String styleType = "균형잡힌 시선";
        String styleDescription = "뚜렷한 호불호 없이 여러 요소를 균형 있게 즐기며, 영화의 전체적인 조화를 중요하게 생각합니다.";

        // 사용자의 '만족도' 편차
        double qualityPref = deviation.getOrDefault("작품성", 0.0);

        // [유형 1] 한 우물 장인: 일관성이 높고, 뚜렷한 대표 장르가 1~2개로 좁혀짐
        if (consistency >= 7.0 && topGenres.size() <= 2 && !topGenres.isEmpty()) {
            styleType = "한 우물 장인";
            styleDescription = String.format("하나의 장르('%s')에 깊이 몰두하여 자신만의 확고한 기준을 구축한 전문가 유형입니다. 당신의 평가는 높은 일관성을 보입니다.", topGenres.get(0));
        }
        // [유형 2] 마이웨이 비평가: 대중의 평가와 내 평가가 확연히 다름 (만족도 편차가 큼)
        else if (qualityPref < -1.5 || qualityPref > 1.5) {
            styleType = "마이웨이 비평가";
            styleDescription = "대중적인 평가나 흥행 여부에 휩쓸리지 않고, 자신만의 뚜렷한 기준으로 영화를 평가하는 독립적인 시선을 가졌습니다.";
        }
        // [유형 3] 자유로운 탐험가: 다양한 장르를 보고, 평가의 일관성은 낮음 (점수를 후하게 주거나 짜게 주는 등)
        else if (topGenres.size() >= 3 && consistency < 5.0) {
            styleType = "자유로운 탐험가";
            styleDescription = "다양한 장르와 스타일을 끊임없이 탐험하며 새로운 자극을 추구하는 모험가와 같습니다. 당신의 평가는 작품에 따라 유연하게 변합니다.";
        }
        // [유형 4] 냉철한 분석가: 평가의 일관성이 매우 높고, 대중의 평가와도 비슷함
        else if (consistency >= 8.0) {
            styleType = "냉철한 분석가";
            styleDescription = "영화의 구조적 완성도나 객관적인 지표를 기준으로, 매우 일관성 있는 평가를 내리는 냉철한 시선을 가지고 있습니다.";
        }
        
        Map<String, String> result = new HashMap<>();
        result.put("style", "#" + styleType);
        result.put("description", styleDescription);
        return result;
    }
}