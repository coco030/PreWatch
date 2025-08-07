package com.springmvc.service;

import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
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
    
    

    private static final String OMDB_API_KEY = "1456190a";
    private static final String OMDB_URL = "http://www.omdbapi.com/";

    // 수동 영화 등록폼에서 영화코드만 입력하면 다 OMDB_API_KEY로 대부분의 정보를 받고, TMDB 키로 배우 정보를 받게 함.
    // OMDB_API_KEY키 팀원과 다르게 새로 발급받은 거라 시범 조회에서는 문제 없을 듯
    public Map<String, Object> getMovieDetailByImdbId(String apiId) {
        Map<String, Object> result = new HashMap<>();
        try {
            String url = UriComponentsBuilder
                .fromHttpUrl(OMDB_URL)
                .queryParam("apikey", OMDB_API_KEY)
                .queryParam("i", apiId)
                .toUriString();

            // OMDb 호출 URL 출력
            System.out.println("[DEBUG] OMDb 호출 URL: " + url);

            String json = restTemplate.getForObject(url, String.class);

            // OMDb 원본 응답 출력
            System.out.println("[DEBUG] OMDb 원본 응답: " + json);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(json);

            // OMDb 실패 케이스도 로그로 확인
            if (root.has("Response") && "False".equalsIgnoreCase(root.get("Response").asText())) {
                System.out.println("[ERROR] OMDb API 에러: " + root.path("Error").asText());
                return result; // 빈 map 반환
            }

            // 파싱된 Title 바로 출력
            String title = root.path("Title").asText(null);
            System.out.println("[DEBUG] 파싱된 Title: " + title);

            result.put("title", title);
            result.put("director", root.path("Director").asText(null));
            result.put("year", parseIntOrZero(root.path("Year").asText(null)));
            result.put("genre", root.path("Genre").asText(null));
            result.put("rated", root.path("Rated").asText(null));
            result.put("overview", root.path("Plot").asText(null));
            result.put("runtime", root.path("Runtime").asText(null));
            result.put("poster_path", root.path("Poster").asText(null));
            result.put("poster_path", root.path("Poster").asText(null));
            
	         // 개봉일(LocalDate) 파싱 추가
	         String releasedStr = root.path("Released").asText(null);
	         LocalDate releaseDate = null;
	         if (releasedStr != null && !releasedStr.equalsIgnoreCase("N/A")) {
	             try {
	                 DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH);
	                 releaseDate = LocalDate.parse(releasedStr, formatter);
	             } catch (Exception e) {
	                 System.out.println("[WARN] 개봉일 날짜 파싱 실패: " + releasedStr);
	             }
	         }
	         result.put("release_date", releaseDate);

	         // =============================================================
	         // 2. TMDB API 호출하여 backdrop_path 가져오기 (이 부분이 추가됩니다)
	         // =============================================================
	         Integer tmdbId = getTmdbMovieId(apiId); // 기존 메서드 재활용
	         if (tmdbId != null) {
	             String tmdbUrl = UriComponentsBuilder
	                 .fromHttpUrl(TMDB_MOVIE_CREDITS_URL + tmdbId) // CREDITS URL 대신 DETAILS URL 사용
	                 .queryParam("api_key", TMDB_API_KEY)
	                 .toUriString();
	             
	             try {
	                 String tmdbJson = restTemplate.getForObject(tmdbUrl, String.class);
	                 JsonNode tmdbRoot = objectMapper.readTree(tmdbJson);
	                 String backdropPath = tmdbRoot.path("backdrop_path").asText(null);
	                 
	                 // backdropPath가 존재할 때만 결과 맵에 추가
	                 if (backdropPath != null && !backdropPath.isEmpty() && !backdropPath.equals("null")) {
	                     result.put("backdrop_path", backdropPath);
	                     System.out.println("[DEBUG] TMDB backdrop_path 추가: " + backdropPath);
	                 } else {
	                     System.out.println("[DEBUG] TMDB backdrop_path 없음: tmdbId=" + tmdbId);
	                 }

	             } catch (Exception e) {
	                 System.out.println("[ERROR] TMDB 상세 정보(backdrop) 조회 실패: tmdbId=" + tmdbId + ", msg=" + e.getMessage());
	             }
	         }
	         // =============================================================

	     } catch (Exception e) {
	         System.out.println("[ERROR] OMDb 영화 정보 파싱 실패: apiId=" + apiId + ", msg=" + e.getMessage());
	     }
	     return result;
	 }
    
    
 // 문자열(String)을 정수(int)로 바꿔주는 "보조 함수
    private int parseIntOrZero(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value.replaceAll("[^\\d]", ""));
        } catch (Exception e) {
            return 0;
        }
    }
    
    // 영화 상세 페이지에 갤러리 추가를 위한 것
    public List<String> getBackdropImageUrls(String apiId) {
        List<String> urls = new ArrayList<>();
        try {
            Integer tmdbMovieId = getTmdbMovieId(apiId); // 이미 존재함
            if (tmdbMovieId == null) return urls;

            String url = UriComponentsBuilder
                .fromHttpUrl("https://api.themoviedb.org/3/movie/" + tmdbMovieId + "/images")
                .queryParam("api_key", TMDB_API_KEY)
                .toUriString();

            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);

            JsonNode backdrops = root.get("backdrops");
            if (backdrops != null && backdrops.isArray()) {
                int count = 0;
                for (JsonNode img : backdrops) {
                    if (count >= 10) break; // 최대 10장까지만
                    String filePath = img.get("file_path").asText();
                    urls.add(filePath);
                    count++;
                }
            }
        } catch (Exception e) {
            System.out.println("[ERROR] 이미지 조회 실패: " + apiId + ", msg=" + e.getMessage());
        }
        return urls;
    }
    
    
  //25.08.07 coco030
    public String getBackdropPath(Integer tmdbMovieId) {
        if (tmdbMovieId == null) {
            return null;
        }
        
        String url = UriComponentsBuilder
            .fromHttpUrl("https://api.themoviedb.org/3/movie/" + tmdbMovieId)
            .queryParam("api_key", TMDB_API_KEY)
            .toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            String backdropPath = root.path("backdrop_path").asText(null);
            
            if (backdropPath != null && !backdropPath.isEmpty() && !backdropPath.equals("null")) {
                return backdropPath;
            }
        } catch (Exception e) {
            System.out.println("[ERROR] TMDB backdrop_path 조회 실패: tmdbId=" + tmdbMovieId);
        }
        return null;
    }
}