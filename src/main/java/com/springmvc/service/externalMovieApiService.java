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
import java.util.ArrayList;       
import java.util.List;            
import java.util.Locale;          

// externalMovieApiService 클래스: 외부 영화 API(OMDb API) 연동 로직 구현.
// 목적: 영화 검색 기능에서 외부 데이터 통합.
@Service // Spring 빈으로 등록
public class externalMovieApiService {

    private static final Logger logger = LoggerFactory.getLogger(externalMovieApiService.class); // Logger 객체 초기화

    private final String OMDB_API_KEY = "c71cc3d8"; // OMDb API 키
    private final String OMDB_BASE_URL = "http://www.omdbapi.com/"; // OMDb API 기본 URL

    private final RestTemplate restTemplate; // 외부 REST API 호출
    private final ObjectMapper objectMapper; // JSON 파싱 및 매핑

    // 생성자: RestTemplate, ObjectMapper 초기화.
    public externalMovieApiService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
        logger.info("externalMovieApiService 초기화 완료.");
    }

    /**
     * searchMoviesByKeyword 메서드: 키워드로 OMDb API에서 영화 목록 검색 및 상세 정보 가져옴.
     * 목적: 사용자 검색어에 해당하는 영화 찾고 상세 정보 채움. OMDb 평점/폭력성지수는 0.0으로 초기화.
     * @param keyword 검색할 영화 키워드.
     * @return 상세 정보가 채워진 영화 목록 (평점/폭력성지수는 0.0).
     */
    public List<movie> searchMoviesByKeyword(String keyword) {
        logger.debug("OMDb API에서 키워드 '{}'로 영화 목록 검색 시도.", keyword);
        String searchApiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("apikey", OMDB_API_KEY)
                .queryParam("s", keyword)
                .build().toUriString();

        List<movie> moviesWithFullDetails = new ArrayList<>();
        try {
            logger.debug("OMDb API 검색 호출 URL: {}", searchApiUrl);
            String jsonResponse = restTemplate.getForObject(searchApiUrl, String.class);
            logger.debug("OMDb API 검색 응답 수신: {}", jsonResponse);

            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            if (rootNode.has("Response") && "True".equalsIgnoreCase(rootNode.get("Response").asText())) {
                JsonNode searchResults = rootNode.get("Search");
                if (searchResults != null && searchResults.isArray()) {
                    for (JsonNode movieNode : searchResults) {
                        String imdbId = movieNode.has("imdbID") ? movieNode.get("imdbID").asText() : null;
                        if (imdbId != null) {
                            movie fullMovieDetail = getMovieFromApi(imdbId); // 상세 정보 재호출
                            if (fullMovieDetail != null) { moviesWithFullDetails.add(fullMovieDetail); }
                        }
                    }
                    logger.info("OMDb API에서 키워드 '{}'로 {}개의 영화 상세 정보 검색 성공.", keyword, moviesWithFullDetails.size());
                }
            } else {
                String errorMessage = rootNode.has("Error") ? rootNode.get("Error").asText() : "Unknown Error";
                logger.warn("OMDb API에서 키워드 '{}'에 대한 영화를 찾지 못했거나 오류 발생: {}", keyword, errorMessage);
            }
        } catch (Exception e) {
            logger.error("OMDb API 검색 호출 또는 응답 파싱 중 오류 발생: {}", e.getMessage(), e);
        }
        return moviesWithFullDetails;
    }

    /**
     * getMovieFromApi 메서드: OMDb API에서 IMDb ID 또는 제목으로 영화 상세 정보 가져옴.
     * 목적: 단일 영화의 모든 상세 정보를 movie 객체로 매핑. 평점/폭력성지수는 0.0으로 고정.
     * @param imdbIdOrTitle 검색할 영화의 IMDb ID 또는 제목.
     * @return 상세 정보가 채워진 movie 객체, 없거나 오류 시 null.
     */
    public movie getMovieFromApi(String imdbIdOrTitle) {
        logger.debug("OMDb API에서 '{}' (imdbID 또는 제목)으로 영화 상세 정보 검색 시도.", imdbIdOrTitle);
        String paramKey = "t";
        if (imdbIdOrTitle != null && imdbIdOrTitle.matches("tt\\d{7,}")) { paramKey = "i"; }
        logger.debug("OMDb API 호출 파라미터: {}={}", paramKey, imdbIdOrTitle);

        String apiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("apikey", OMDB_API_KEY)
                .queryParam(paramKey, imdbIdOrTitle)
                .build().toUriString();

        try {
            logger.debug("OMDb API 상세 정보 호출 URL: {}", apiUrl);
            String jsonResponse = restTemplate.getForObject(apiUrl, String.class);
            logger.debug("OMDb API 상세 정보 응답 수신: {}", jsonResponse);

            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            if (rootNode.has("Response") && "True".equalsIgnoreCase(rootNode.get("Response").asText())) {
                movie movie = new movie();
                movie.setApiId(rootNode.has("imdbID") ? rootNode.get("imdbID").asText() : null);
                movie.setTitle(rootNode.has("Title") ? rootNode.get("Title").asText() : "N/A");
                movie.setDirector(rootNode.has("Director") ? rootNode.get("Director").asText() : "N/A");
                movie.setYear(rootNode.has("Year") ? Integer.parseInt(rootNode.get("Year").asText().split("–")[0]) : 0);

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

                movie.setRating(0.0);             // OMDb 평점 무시, 0.0으로 고정
                movie.setviolence_score_avg(0.0); // OMDb 폭력성지수 무시, 0.0으로 고정

                logger.info("OMDb API에서 영화 '{}' (ID: {}) 정보 성공적으로 파싱. 평점/폭력성지수는 0.0으로 설정됨.", movie.getTitle(), movie.getApiId());
                return movie;
            } else {
                String errorMessage = rootNode.has("Error") ? rootNode.get("Error").asText() : "Unknown Error";
                logger.warn("OMDb API에서 '{}'를 찾지 못했거나 오류 발생: {}", imdbIdOrTitle, errorMessage);
                return null;
            }
        } catch (Exception e) {
            logger.error("OMDb API 호출 또는 응답 파싱 중 오류 발생: {}", e.getMessage(), e);
            return null;
        }
    }
}