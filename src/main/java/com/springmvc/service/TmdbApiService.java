package com.springmvc.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class TmdbApiService {

    private static final String TMDB_API_KEY = "6ec1d7b0638f8e641a7b32f82aa333b8";
    private static final String TMDB_FIND_URL = "https://api.themoviedb.org/3/find/";
    private static final String TMDB_MOVIE_CREDITS_URL = "https://api.themoviedb.org/3/movie/";

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 1. IMDb ID로 TMDB의 영화 ID 조회
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
            // 생략: 오류 시 null 반환
        }
        return null;
    }

    // 2. TMDB 영화 ID로 감독/배우 정보 가져오기
    public List<Map<String, String>> getCastAndCrew(Integer tmdbMovieId) {
        String url = UriComponentsBuilder
            .fromHttpUrl(TMDB_MOVIE_CREDITS_URL + tmdbMovieId + "/credits")
            .queryParam("api_key", TMDB_API_KEY)
            .toUriString();

        List<Map<String, String>> result = new ArrayList<>();
        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);

            // 배우 정보 (최대 5명)
            JsonNode cast = root.get("cast");
            for (int i = 0; i < Math.min(5, cast.size()); i++) {
                JsonNode person = cast.get(i);
                Map<String, String> info = new HashMap<>();
                info.put("name", person.get("name").asText());
                info.put("profile_path", person.get("profile_path").asText(null));
                info.put("role", person.get("character").asText());
                info.put("type", "ACTOR");
                result.add(info);
            }

            // 감독 정보 (1명만)
            JsonNode crew = root.get("crew");
            for (JsonNode member : crew) {
                if ("Director".equalsIgnoreCase(member.get("job").asText())) {
                    Map<String, String> info = new HashMap<>();
                    info.put("name", member.get("name").asText());
                    info.put("profile_path", member.get("profile_path").asText(null));
                    info.put("type", "DIRECTOR");
                    result.add(info);
                    break;
                }
            }
        } catch (Exception e) {
            // 생략: 오류 시 빈 리스트 반환
        }
        return result;
    }
}
