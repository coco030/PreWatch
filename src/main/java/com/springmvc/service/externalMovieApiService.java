package com.springmvc.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springmvc.domain.movie; // movie 도메인 클래스가 있다고 가정
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

    /**
     * 키워드를 사용하여 OMDb API에서 영화 목록을 검색합니다.
     * 이 메서드는 사용자가 입력한 검색어에 해당하는 모든 영화를 찾습니다.
     *
     * @param keyword 검색할 영화 키워드 (예: "ring")
     * @return 검색된 영화 목록 (제목, 연도, imdbID, 포스터 등 간략 정보)
     */
    public List<movie> searchMoviesByKeyword(String keyword) {
        logger.debug("OMDb API에서 키워드 '{}'로 영화 목록 검색 시도.", keyword);

        String apiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("apikey", OMDB_API_KEY)
                .queryParam("s", keyword) // 's' 파라미터를 사용하여 부분 일치 검색
                .build()
                .toUriString();

        List<movie> movies = new ArrayList<>();
        try {
            logger.debug("OMDb API 호출 URL: {}", apiUrl);
            String jsonResponse = restTemplate.getForObject(apiUrl, String.class);
            logger.debug("OMDb API 응답 수신: {}", jsonResponse);

            JsonNode rootNode = objectMapper.readTree(jsonResponse);

            if (rootNode.has("Response") && "True".equalsIgnoreCase(rootNode.get("Response").asText())) {
                JsonNode searchResults = rootNode.get("Search");
                if (searchResults != null && searchResults.isArray()) {
                    for (JsonNode movieNode : searchResults) {
                        movie movie = new movie();
                        // 검색 결과에서는 상세 정보를 모두 제공하지 않으므로, 필요한 최소한의 정보만 파싱
                        movie.setApiId(movieNode.has("imdbID") ? movieNode.get("imdbID").asText() : null);
                        movie.setTitle(movieNode.has("Title") ? movieNode.get("Title").asText() : "N/A");
                        movie.setYear(movieNode.has("Year") ? Integer.parseInt(movieNode.get("Year").asText().split("–")[0]) : 0);
                        movie.setPosterPath(movieNode.has("Poster") ? movieNode.get("Poster").asText() : "N/A");
                        movies.add(movie);
                    }
                    logger.info("OMDb API에서 키워드 '{}'로 {}개의 영화 검색 성공.", keyword, movies.size());
                }
            } else {
                String errorMessage = rootNode.has("Error") ? rootNode.get("Error").asText() : "Unknown Error";
                logger.warn("OMDb API에서 키워드 '{}'에 대한 영화를 찾지 못했거나 오류 발생: {}", keyword, errorMessage);
            }

        } catch (Exception e) {
            logger.error("OMDb API 호출 또는 응답 파싱 중 오류 발생: {}", e.getMessage(), e);
        }
        return movies;
    }

 
    public movie getMovieFromApi(String imdbIdOrTitle) { // 메서드 이름 유지, 파라미터 이름은 역할에 맞게 변경
        logger.debug("OMDb API에서 '{}' (imdbID 또는 제목)으로 영화 상세 정보 검색 시도.", imdbIdOrTitle);

        // 'imdbIdOrTitle'이 imdbID 형식인지 (tt로 시작하는지) 확인하여 'i' 또는 't' 파라미터를 동적으로 선택
        String paramKey = "t"; // 기본값은 제목 검색
        if (imdbIdOrTitle != null && imdbIdOrTitle.matches("tt\\d{7,}")) { // imdbID 형식 (예: tt1234567)
            paramKey = "i"; // imdbID로 검색
        }
        // 로그에 어떤 파라미터로 호출되는지 명확히 표시
        logger.debug("OMDb API 호출 파라미터: {}={}", paramKey, imdbIdOrTitle);


        String apiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("apikey", OMDB_API_KEY)
                .queryParam(paramKey, imdbIdOrTitle) // 동적으로 파라미터 키 설정
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
                logger.warn("OMDb API에서 '{}'를 찾지 못했거나 오류 발생: {}", imdbIdOrTitle, errorMessage);
                return null;
            }

        } catch (Exception e) {
            logger.error("OMDb API 호출 또는 응답 파싱 중 오류 발생: {}", e.getMessage(), e);
            return null;
        }
    }
}