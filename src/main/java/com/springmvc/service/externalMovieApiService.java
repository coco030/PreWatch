package com.springmvc.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springmvc.domain.movie;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;

@Service
public class externalMovieApiService {

    private static final Logger logger = LoggerFactory.getLogger(externalMovieApiService.class);

    private final String OMDB_API_KEY = "c71cc3d8"; // 발급받은 OMDb API 키
    private final String OMDB_BASE_URL = "http://www.omdbapi.com/";

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public externalMovieApiService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
        logger.info("externalMovieApiService 초기화 완료.");
    }

    public movie getMovieFromApi(String title) {
        logger.debug("OMDb API에서 영화 '{}' 검색 시도.", title);

        String apiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("apikey", OMDB_API_KEY)
                .queryParam("t", title)
                .build()
                .toUriString();

        try {
            logger.debug("OMDb API 호출 URL: {}", apiUrl);
            String jsonResponse = restTemplate.getForObject(apiUrl, String.class);
            logger.debug("OMDb API 응답 수신: {}", jsonResponse);

            JsonNode rootNode = objectMapper.readTree(jsonResponse);

            if (rootNode.has("Response") && "True".equalsIgnoreCase(rootNode.get("Response").asText())) {
                movie movie = new movie();

                movie.setApiId(rootNode.has("imdbID") ? rootNode.get("imdbID").asText() : null);
                movie.setTitle(rootNode.has("Title") ? rootNode.get("Title").asText() : "N/A");
                movie.setDirector(rootNode.has("Director") ? rootNode.get("Director").asText() : "N/A");
                movie.setYear(rootNode.has("Year") ? Integer.parseInt(rootNode.get("Year").asText().split("–")[0]) : 0);

                // 날짜 파싱 처리
                if (rootNode.has("Released")) {
                    String released = rootNode.get("Released").asText();
                    if (!"N/A".equalsIgnoreCase(released)) {
                        try {
                            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.ENGLISH);
                            LocalDate releaseDate = LocalDate.parse(released, formatter);
                            movie.setReleaseDate(releaseDate);
                        } catch (DateTimeParseException e) {
                            logger.warn("날짜 파싱 실패: '{}', 예외: {}", released, e.getMessage());
                        }
                    }
                }

                movie.setGenre(rootNode.has("Genre") ? rootNode.get("Genre").asText() : "N/A");
                movie.setOverview(rootNode.has("Plot") ? rootNode.get("Plot").asText() : "N/A");
                movie.setPosterPath(rootNode.has("Poster") ? rootNode.get("Poster").asText() : "N/A");

                logger.info("OMDb API에서 영화 '{}' ({}) 정보 성공적으로 파싱.", movie.getTitle(), movie.getApiId());
                return movie;
            } else {
                String errorMessage = rootNode.has("Error") ? rootNode.get("Error").asText() : "Unknown Error";
                logger.warn("OMDb API에서 영화 '{}'를 찾지 못했거나 오류 발생: {}", title, errorMessage);
                return null;
            }

        } catch (Exception e) {
            logger.error("OMDb API 호출 또는 응답 파싱 중 오류 발생: {}", e.getMessage(), e);
            return null;
        }
    }
}
