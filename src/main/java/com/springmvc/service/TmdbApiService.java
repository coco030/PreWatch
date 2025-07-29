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

    private static final int MAX_CAST_COUNT = 5;
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

            JsonNode crew = root.get("crew");
            for (JsonNode member : crew) {
                if ("Director".equalsIgnoreCase(member.get("job").asText())) {
                    Map<String, String> info = new HashMap<>();
                    info.put("name", member.get("name").asText());
                    info.put("profile_path", member.get("profile_path").asText(null));
                    info.put("type", "DIRECTOR");
                    info.put("role", member.get("job").asText());
                    info.put("tmdb_id", member.get("id").asText());
                    result.add(info);
                    break;
                }
            }
        } catch (Exception e) {
            System.out.println("[ERROR] TMDB 출연진 정보 파싱 실패: movieId=" + tmdbMovieId);
        }
        return result;
    }

    // ⭐ [추가] TMDB 인물 상세 정보 가져오기
    public Map<String, Object> getPersonDetailFromTmdb(Integer tmdbId) {
        String url = UriComponentsBuilder
            .fromHttpUrl(TMDB_PERSON_DETAIL_URL + tmdbId)
            .queryParam("api_key", TMDB_API_KEY)
            .toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);

            Map<String, Object> details = new HashMap<>();
            // birthday로부터 age 계산
            String birthdayStr = root.get("birthday").asText(null);
            details.put("birthday", birthdayStr);

            if (birthdayStr != null) {
                try {
                    LocalDate birthday = LocalDate.parse(birthdayStr); // yyyy-MM-dd 형식 전제
                    int age = Period.between(birthday, LocalDate.now()).getYears();
                    details.put("age", age);
                } catch (DateTimeParseException e) {
                    System.out.println("[WARN] 생일 날짜 파싱 실패: " + birthdayStr);
                    details.put("age", null);
                }
            } else {
                details.put("age", null);
            }
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

            // ⭐ [추가] 상세 정보 받아와 업데이트
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
}