package com.springmvc.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springmvc.repository.ActorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value; // @Value 임포트
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;

@Service
public class TmdbApiService {

    private final ActorRepository actorRepository;

    private static final int MAX_CAST_COUNT = 11;


    private final String tmdbApiKey;
    private final String omdbDetailApiKey;

    private static final String TMDB_FIND_URL = "https://api.themoviedb.org/3/find/";
    private static final String TMDB_MOVIE_CREDITS_URL = "https://api.themoviedb.org/3/movie/";
    private static final String TMDB_PERSON_DETAIL_URL = "https://api.themoviedb.org/3/person/";
    private static final String OMDB_URL = "http://www.omdbapi.com/";

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

 
    @Autowired
    public TmdbApiService(
            ActorRepository actorRepository,
            @Value("${tmdb.api.key}") String tmdbApiKey,
            @Value("${omdb.api.key.detail}") String omdbDetailApiKey) {
        this.actorRepository = actorRepository;
        this.tmdbApiKey = tmdbApiKey;
        this.omdbDetailApiKey = omdbDetailApiKey;
    }

    public Integer getTmdbMovieId(String imdbId) {
        String url = UriComponentsBuilder.fromHttpUrl(TMDB_FIND_URL + imdbId)
                .queryParam("api_key", this.tmdbApiKey) // [수정] 주입받은 키 사용
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
                .queryParam("api_key", this.tmdbApiKey) 
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
                String job = member.get("job").asText();
                if ("Director".equalsIgnoreCase(job)) {
                    Map<String, String> info = new HashMap<>();
                    info.put("name", member.get("name").asText());
                    info.put("profile_path", member.get("profile_path").asText(null));
                    info.put("role", getKoreanJobName(job));
                    info.put("type", "DIRECTOR");
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

    public Map<String, Object> getPersonDetailFromTmdb(Integer tmdbId) {
        String url = UriComponentsBuilder
                .fromHttpUrl(TMDB_PERSON_DETAIL_URL + tmdbId)
                .queryParam("api_key", this.tmdbApiKey) 
                .toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            Map<String, Object> details = new HashMap<>();
            String birthdayStr = root.get("birthday").asText(null);
            String deathdayStr = root.get("deathday").asText(null);
            details.put("birthday", birthdayStr);
            details.put("deathday", deathdayStr);
            if (birthdayStr != null) {
                try {
                    LocalDate birthday = LocalDate.parse(birthdayStr);
                    LocalDate endDate = (deathdayStr != null) ? LocalDate.parse(deathdayStr) : LocalDate.now();
                    int age = Period.between(birthday, endDate).getYears();
                    details.put("age", age);
                } catch (DateTimeParseException e) {
                    System.out.println("[WARN] 생일 또는 사망일 날짜 파싱 실패: " + birthdayStr + ", " + deathdayStr);
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
        Map<String, String> jobMap = Map.ofEntries(Map.entry("Director", "감독"), Map.entry("Producer", "프로듀서"), Map.entry("Executive Producer", "총괄 프로듀서"), Map.entry("Writer", "작가"), Map.entry("Screenplay", "각본"), Map.entry("Story", "원작"), Map.entry("Original Music Composer", "음악"), Map.entry("Sound Re-Recording Mixer", "음향 믹싱"), Map.entry("Sound Editor", "음향 편집"), Map.entry("Editor", "편집"), Map.entry("Director of Photography", "촬영 감독"), Map.entry("Cinematography", "촬영"), Map.entry("Costume Designer", "의상 디자이너"), Map.entry("Makeup Artist", "메이크업"), Map.entry("Production Design", "미술"), Map.entry("Art Direction", "아트 디렉션"), Map.entry("Set Decoration", "세트 장식"), Map.entry("Visual Effects Supervisor", "VFX 감독"), Map.entry("Animation", "애니메이션"), Map.entry("Casting", "캐스팅"), Map.entry("Stunt Coordinator", "스턴트 조정"), Map.entry("Lighting Technician", "조명"), Map.entry("Sound Designer", "사운드 디자인"));
        return jobMap.getOrDefault(job, job);
    }

    public Map<String, Object> getMovieDetailByImdbId(String apiId) {
        Map<String, Object> result = new HashMap<>();
        try {
            String url = UriComponentsBuilder
                    .fromHttpUrl(OMDB_URL)
                    .queryParam("apikey", this.omdbDetailApiKey) // [수정] 주입받은 키 사용
                    .queryParam("i", apiId)
                    .toUriString();
            
            System.out.println("[DEBUG] OMDb 호출 URL: " + url);
            String json = restTemplate.getForObject(url, String.class);
            System.out.println("[DEBUG] OMDb 원본 응답: " + json);
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(json);
            if (root.has("Response") && "False".equalsIgnoreCase(root.get("Response").asText())) {
                System.out.println("[ERROR] OMDb API 에러: " + root.path("Error").asText());
                return result;
            }
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

            Integer tmdbId = getTmdbMovieId(apiId);
            if (tmdbId != null) {
                 String tmdbUrl = UriComponentsBuilder
	                 .fromHttpUrl(TMDB_MOVIE_CREDITS_URL + tmdbId)
	                 .queryParam("api_key", this.tmdbApiKey) // [수정] 주입받은 키 사용
	                 .toUriString();
                 
                 try {
	                 String tmdbJson = restTemplate.getForObject(tmdbUrl, String.class);
	                 JsonNode tmdbRoot = objectMapper.readTree(tmdbJson);
	                 String backdropPath = tmdbRoot.path("backdrop_path").asText(null);
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
        } catch (Exception e) {
            System.out.println("[ERROR] OMDb 영화 정보 파싱 실패: apiId=" + apiId + ", msg=" + e.getMessage());
        }
        return result;
    }

    private int parseIntOrZero(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value.replaceAll("[^\\d]", ""));
        } catch (Exception e) {
            return 0;
        }
    }

    public List<String> getBackdropImageUrls(String apiId) {
        List<String> urls = new ArrayList<>();
        try {
            Integer tmdbMovieId = getTmdbMovieId(apiId);
            if (tmdbMovieId == null) return urls;

            String url = UriComponentsBuilder
                    .fromHttpUrl("https://api.themoviedb.org/3/movie/" + tmdbMovieId + "/images")
                    .queryParam("api_key", this.tmdbApiKey) // [수정] 주입받은 키 사용
                    .toUriString();
            
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            JsonNode backdrops = root.get("backdrops");
            if (backdrops != null && backdrops.isArray()) {
                int count = 0;
                for (JsonNode img : backdrops) {
                    if (count >= 10) break;
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

    public String getBackdropPath(Integer tmdbMovieId) {
        if (tmdbMovieId == null) {
            return null;
        }

        String url = UriComponentsBuilder
                .fromHttpUrl("https://api.themoviedb.org/3/movie/" + tmdbMovieId)
                .queryParam("api_key", this.tmdbApiKey)
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