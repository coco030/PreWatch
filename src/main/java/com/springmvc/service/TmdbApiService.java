package com.springmvc.service;

import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springmvc.repository.ActorRepository;

@Service
public class TmdbApiService {

    @Autowired
    private ActorRepository actorRepository;

    private static final int MAX_CAST_COUNT = 11;
    private static final String TMDB_API_KEY = "6ec1d7b0638f8e641a7b32f82aa333b8";
    private static final String TMDB_FIND_URL = "https://api.themoviedb.org/3/find/";
    private static final String TMDB_MOVIE_CREDITS_URL = "https://api.themoviedb.org/3/movie/";
    private static final String TMDB_PERSON_DETAIL_URL = "https://api.themoviedb.org/3/person/";

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public Integer getTmdbMovieId(String imdbId) {
        String url = UriComponentsBuilder.fromHttpUrl(TMDB_FIND_URL + imdbId)
            .queryParam("api_key", TMDB_API_KEY)
            .queryParam("external_source", "imdb_id")
            .toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            JsonNode movieResults = root.get("movie_results");
            if (movieResults != null && movieResults.isArray() && movieResults.size() > 0) {
                return movieResults.get(0).get("id").asInt();
            }
        } catch (Exception e) {
            System.out.println("[ERROR] TMDB 영화 ID 조회 실패: imdbId=" + imdbId);
        }
        return null;
    }


    public List<Map<String, String>> getCastAndCrew(Integer tmdbMovieId) {
        String url = UriComponentsBuilder
            .fromHttpUrl(TMDB_MOVIE_CREDITS_URL + tmdbMovieId + "/credits")
            .queryParam("api_key", TMDB_API_KEY)
            .toUriString();

        List<Map<String, String>> result = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);

            //  cast (배우/성우)
            JsonNode cast = root.get("cast");
            for (int i = 0; i < Math.min(MAX_CAST_COUNT, cast.size()); i++) {
                JsonNode person = cast.get(i);
                Map<String, String> info = new HashMap<>();
                info.put("name", person.get("name").asText());
                info.put("profile_path", person.get("profile_path").asText(null));
                info.put("role", person.get("character").asText());
                info.put("type", "ACTOR");
                info.put("tmdb_id", person.get("id").asText());
                result.add(info);
            }

            //  crew (감독 1명만)
            JsonNode crew = root.get("crew");
            for (JsonNode member : crew) {
                String job = member.get("job").asText();
                if ("Director".equalsIgnoreCase(job)) {
                    Map<String, String> info = new HashMap<>();
                    info.put("name", member.get("name").asText());
                    info.put("profile_path", member.get("profile_path").asText(null));
                    info.put("role", getKoreanJobName(job)); // "감독"
                    info.put("type", "DIRECTOR");
                    info.put("tmdb_id", member.get("id").asText());
                    result.add(info);
                    break; // 한 명만
                }
            }

        } catch (Exception e) {
            System.out.println("[ERROR] TMDB 출연진 정보 파싱 실패: movieId=" + tmdbMovieId);
        }

        return result;
    }
    
    // [수정됨] TMDB 인물 상세 정보 가져오기 (사망자 나이 계산 보정 포함)
    public Map<String, Object> getPersonDetailFromTmdb(Integer tmdbId) {
        String url = UriComponentsBuilder
            .fromHttpUrl(TMDB_PERSON_DETAIL_URL + tmdbId)
            .queryParam("api_key", TMDB_API_KEY)
            .toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);

            Map<String, Object> details = new HashMap<>();

            // 생일 및 사망일 정보
            String birthdayStr = root.get("birthday").asText(null);
            String deathdayStr = root.get("deathday").asText(null);
            details.put("birthday", birthdayStr);
            details.put("deathday", deathdayStr);

            // 나이 계산: 사망일 기준 또는 현재 날짜 기준
            if (birthdayStr != null) {
                try {
                    LocalDate birthday = LocalDate.parse(birthdayStr); // yyyy-MM-dd 형식 전제
                    LocalDate endDate;

                    if (deathdayStr != null) {
                        endDate = LocalDate.parse(deathdayStr);
                    } else {
                        endDate = LocalDate.now();
                    }

                    int age = Period.between(birthday, endDate).getYears();
                    details.put("age", age);
                } catch (DateTimeParseException e) {
                    System.out.println("[WARN] 생일 또는 사망일 날짜 파싱 실패: " + birthdayStr + ", " + deathdayStr);
                    details.put("age", null);
                }
            } else {
                details.put("age", null);
            }

            // 기타 정보
            details.put("place_of_birth", root.get("place_of_birth").asText(null));
            details.put("biography", root.get("biography").asText(null));
            details.put("gender", root.get("gender").asInt(-1));
            details.put("known_for_department", root.get("known_for_department").asText(null));

            return details;

        } catch (Exception e) {
            System.out.println("[ERROR] TMDB 인물 상세정보 실패: tmdb_id=" + tmdbId);
            return null;
        }
    }


    public void saveCastAndCrew(Long movieId, List<Map<String, String>> castAndCrew) {
        int displayOrder = 0;
        System.out.println("saveCastAndCrew: movieId=" + movieId + ", castAndCrew.size=" + castAndCrew.size());

        for (Map<String, String> person : castAndCrew) {
            String name = person.get("name");
            String roleType = person.get("type");
            String profileImageUrl = person.get("profile_path");
            String roleName = person.get("role");
        
            Integer tmdbId = person.containsKey("tmdb_id") ? Integer.parseInt(person.get("tmdb_id")) : null;

            Long actorId = actorRepository.findByNameOrInsert(name, profileImageUrl, tmdbId);
            if (actorId == null) {
                System.out.println("[ERROR] 배우 DB 저장 실패, 매핑 생략 name=" + name);
                continue;
            }

            // 중복 선언 제거 + 내부 메서드 직접 호출
            if (tmdbId != null) {
                Map<String, Object> details = getPersonDetailFromTmdb(tmdbId);
                if (details != null) {
                    actorRepository.updateActorDetails(actorId, details);
                }
            }
            actorRepository.saveMovieActorMapping(movieId, actorId, roleName, roleType, displayOrder);
            displayOrder++;
        }
    }
    
    private String getKoreanJobName(String job) {
        Map<String, String> jobMap = Map.ofEntries(
            Map.entry("Director", "감독"),
            Map.entry("Producer", "프로듀서"),
            Map.entry("Executive Producer", "총괄 프로듀서"),
            Map.entry("Writer", "작가"),
            Map.entry("Screenplay", "각본"),
            Map.entry("Story", "원작"),
            Map.entry("Original Music Composer", "음악"),
            Map.entry("Sound Re-Recording Mixer", "음향 믹싱"),
            Map.entry("Sound Editor", "음향 편집"),
            Map.entry("Editor", "편집"),
            Map.entry("Director of Photography", "촬영 감독"),
            Map.entry("Cinematography", "촬영"),
            Map.entry("Costume Designer", "의상 디자이너"),
            Map.entry("Makeup Artist", "메이크업"),
            Map.entry("Production Design", "미술"),
            Map.entry("Art Direction", "아트 디렉션"),
            Map.entry("Set Decoration", "세트 장식"),
            Map.entry("Visual Effects Supervisor", "VFX 감독"),
            Map.entry("Animation", "애니메이션"),
            Map.entry("Casting", "캐스팅"),
            Map.entry("Stunt Coordinator", "스턴트 조정"),
            Map.entry("Lighting Technician", "조명"),
            Map.entry("Sound Designer", "사운드 디자인")
           
        );

        return jobMap.getOrDefault(job, job); // 모르는 건 원문 그대로
    }

}