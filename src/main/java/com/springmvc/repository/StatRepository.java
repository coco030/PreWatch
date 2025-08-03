package com.springmvc.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.StatDTO;
import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.domain.UserReviewScoreDTO;

@Repository
public class StatRepository {
	
	 @Autowired
	 private NamedParameterJdbcTemplate namedParameterJdbcTemplate;
	 
	@Autowired
    private JdbcTemplate jdbcTemplate;

	private final RowMapper<StatDTO> genreAvgRowMapper = new RowMapper<StatDTO>() {
	    @Override
	    public StatDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
	        StatDTO dto = new StatDTO();
	        dto.setGenres(Collections.singletonList(rs.getString("genre"))); // 장르 정보
	        dto.setGenreRatingAvg(rs.getDouble("avg_rating"));               // 작품성 평균
	        dto.setGenreViolenceScoreAvg(rs.getDouble("avg_violence"));      // 폭력성 평균
	        dto.setGenreHorrorScoreAvg(rs.getDouble("avg_horror"));          // 공포성 평균
	        dto.setGenreSexualScoreAvg(rs.getDouble("avg_sexual"));          // 선정성 평균
	        return dto;
	    }
	};
    
    // 1. 특정 영화의 장르 목록 가져오기
    public List<String> findGenresByMovieId(long movieId) {
        String sql = "SELECT genre FROM movie_genres WHERE movie_id = ?";
        return jdbcTemplate.queryForList(sql, String.class, movieId);
    }

    // 2. 특정 영화의 기본 정보 및 통계 가져오기 (두 테이블 JOIN)

    public StatDTO findMovieStatsById(long movieId) {
        String sql = "SELECT " +
                "    m.id, " +
                "    m.title, " +
                "    m.rating, " +
                "    m.violence_score_avg, " +
                "    m.rated, " + // 영화 등급 추가
                "    ms.horror_score_avg, " +
                "    ms.sexual_score_avg, " +
                "    ms.review_count " +
                "FROM movies m " +
                "LEFT JOIN movie_stats ms ON m.id = ms.movie_id " +
                "WHERE m.id = ?";

        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                StatDTO dto = new StatDTO();
                dto.setMovieId(rs.getLong("id"));
                dto.setTitle(rs.getString("title"));
                dto.setUserRatingAvg(rs.getDouble("rating"));
                dto.setViolenceScoreAvg(rs.getDouble("violence_score_avg"));
                dto.setRated(rs.getString("rated")); // rated 세팅
                dto.setHorrorScoreAvg(rs.getDouble("horror_score_avg"));
                if (rs.wasNull()) dto.setHorrorScoreAvg(0.0);
                dto.setSexualScoreAvg(rs.getDouble("sexual_score_avg"));
                if (rs.wasNull()) dto.setSexualScoreAvg(0.0);
                dto.setReviewCount(rs.getInt("review_count"));
                if (rs.wasNull()) dto.setReviewCount(0);
                return dto;
            }, movieId);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null; // 영화가 존재하지 않는 경우
        }
    }


 // 3. 특정 장르의 평균 점수 계산하기 - 전체 필드 출력
    public StatDTO getGenreAverageScores(String genre) {
        String sql = "SELECT " +
                     "    mg.genre AS genre, " +  
                     "    COALESCE(AVG(m.rating), 0.0) as avg_rating, " +
                     "    COALESCE(AVG(m.violence_score_avg), 0.0) as avg_violence, " +
                     "    COALESCE(AVG(ms.horror_score_avg), 0.0) as avg_horror, " +
                     "    COALESCE(AVG(ms.sexual_score_avg), 0.0) as avg_sexual " +
                     "FROM movies m " +
                     "JOIN movie_genres mg ON m.id = mg.movie_id " +
                     "LEFT JOIN movie_stats ms ON m.id = ms.movie_id " +
                     "WHERE mg.genre = ? " +
                     "GROUP BY mg.genre";

        return jdbcTemplate.queryForObject(sql, genreAvgRowMapper, genre);
    }

    

    // 유저 상세 점수 분석
    public List<UserReviewScoreDTO> findUserReviewScoresForAnalysis(String memberId) {
        String sql = "SELECT " +
                     "    user_rating as userRating, " +
                     "    violence_score as violenceScore, " +
                     "    horror_score as horrorScore, " +
                     "    sexual_score as sexualScore " +
                     "FROM user_reviews " +
                     "WHERE member_id = :memberId";

        Map<String, String> params = Collections.singletonMap("memberId", memberId);
        
        return namedParameterJdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(UserReviewScoreDTO.class));
    }
    
    // 유저 상세 프로필 
    public List<TasteAnalysisDataDTO> findTasteAnalysisData(String memberId) {
        String sql = "SELECT " +
                     "    ur.movie_id AS movieId, " + // 이 부분이 DTO의 movieId 필드와 매핑
                     "    ur.user_rating AS myUserRating, " +
                     "    ur.violence_score AS myViolenceScore, " +
                     "    ur.horror_score AS myHorrorScore, " +
                     "    ur.sexual_score AS mySexualScore, " +
                     "    m.rating AS movieAvgRating, " +
                     "    m.violence_score_avg AS movieAvgViolence, " +
                     "    ms.horror_score_avg AS movieAvgHorror, " +
                     "    ms.sexual_score_avg AS movieAvgSexual " +
                     "FROM user_reviews ur " +
                     "JOIN movies m ON ur.movie_id = m.id " +
                     "LEFT JOIN movie_stats ms ON ur.movie_id = ms.movie_id " +
                     "WHERE ur.member_id = :memberId AND ur.user_rating IS NOT NULL";
        
        Map<String, String> params = Collections.singletonMap("memberId", memberId);
        return namedParameterJdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(TasteAnalysisDataDTO.class));
    }

    public List<StatDTO> findSimilarMoviesWithGenres(
            double userRatingAvg,
            double violenceScoreAvg,
            double horrorScoreAvg,
            double sexualScoreAvg,
            List<String> genres,
            List<String> allowedRatings,
            long baseMovieId) {

        // 장르 또는 등급 목록이 비어 있으면 빈 결과 반환
        if (genres.isEmpty() || allowedRatings.isEmpty()) {
            return Collections.emptyList();
        }

        String genrePlaceholders = String.join(",", Collections.nCopies(genres.size(), "?"));
        String ratedPlaceholders = String.join(",", Collections.nCopies(allowedRatings.size(), "?"));

        String sql = "SELECT m.id AS movie_id, m.title, m.rated, m.rating, m.violence_score_avg, " +
                "       s.horror_score_avg, s.sexual_score_avg, m.poster_path, " +
                "       SUM(CASE WHEN mg.genre IN (" + genrePlaceholders + ") THEN 1 ELSE 0 END) AS genre_match_count, " +
                "       (ABS(IFNULL(m.rating, 0) - ?) + " +
                "        ABS(IFNULL(m.violence_score_avg, 0) - ?) + " +
                "        ABS(IFNULL(s.horror_score_avg, 0) - ?) + " +
                "        ABS(IFNULL(s.sexual_score_avg, 0) - ?)) AS total_score_diff " +
                "FROM movies m " +
                "LEFT JOIN movie_stats s ON m.id = s.movie_id " +
                "JOIN movie_genres mg ON m.id = mg.movie_id " +
                "WHERE m.id != ? " +
                "  AND m.rated IN (" + ratedPlaceholders + ") " +
                "GROUP BY m.id, m.title, m.rated, m.rating, m.violence_score_avg, s.horror_score_avg, s.sexual_score_avg " +
                "HAVING genre_match_count >= 1 " +
                "ORDER BY genre_match_count DESC, total_score_diff ASC " +
                "LIMIT 10";

        List<Object> params = new ArrayList<>();
        params.addAll(genres);
        params.add(userRatingAvg);
        params.add(violenceScoreAvg);
        params.add(horrorScoreAvg);
        params.add(sexualScoreAvg);
        params.add(baseMovieId);
        params.addAll(allowedRatings);

        return jdbcTemplate.query(sql, params.toArray(), (rs, rowNum) -> {
            StatDTO dto = new StatDTO();
            dto.setMovieId(rs.getLong("movie_id"));
            dto.setTitle(rs.getString("title"));
            dto.setRated(rs.getString("rated"));
            dto.setUserRatingAvg(rs.getDouble("rating"));
            dto.setViolenceScoreAvg(rs.getDouble("violence_score_avg"));
            dto.setHorrorScoreAvg(rs.getDouble("horror_score_avg"));
            dto.setSexualScoreAvg(rs.getDouble("sexual_score_avg"));
            dto.setPosterPath(rs.getString("poster_path")); 
            return dto;
        });
    }

    // 로그인 사용자를 위한 개선된 추천 쿼리 (가중치 반영)
    public List<StatDTO> findSimilarMoviesForLoggedInUser(
            double userRatingAvg,
            double violenceScoreAvg,
            double horrorScoreAvg,
            double sexualScoreAvg,
            List<String> genres,
            List<String> allowedRatings,
            long baseMovieId,
            Map<String, Double> userPreferences) {

       // 장르가 하나 이상일 경우에만 추천
    	if (genres.isEmpty() || allowedRatings.isEmpty()) {
    	    return Collections.emptyList();
    	}
    // 장르 정보와 쿼리 매개변수 로그 출력
       System.out.println("[DEBUG] 장르 정보: " + genres);
       System.out.println("[DEBUG] 추천 쿼리 실행 - 기준 영화 ID: " + baseMovieId);
       
       // IN 절을 위한 placeholder 생성
       String genrePlaceholders = String.join(",", Collections.nCopies(genres.size(), "?"));
       String ratedPlaceholders = String.join(",", Collections.nCopies(allowedRatings.size(), "?"));

       // 사용자 선호도 가중치 계산
       double ratingWeight = 1.0 + Math.abs(userPreferences.getOrDefault("작품성", 0.0)) * 0.3;
       double violenceWeight = 1.0 + Math.abs(userPreferences.getOrDefault("액션", 0.0)) * 0.3;
       double horrorWeight = 1.0 + Math.abs(userPreferences.getOrDefault("스릴", 0.0)) * 0.3;
       double sexualWeight = 1.0 + Math.abs(userPreferences.getOrDefault("감성", 0.0)) * 0.3;

       String sql = "SELECT m.id AS movie_id, m.title, m.rated, m.rating, m.violence_score_avg, " +
               "       s.horror_score_avg, s.sexual_score_avg, m.poster_path, " +
               "       SUM(CASE WHEN mg.genre IN (" + genrePlaceholders + ") THEN 1 ELSE 0 END) AS genre_match_count, " +
               "       (ABS(IFNULL(m.rating, 0) - ?) * ? + " +  // 작품성 가중치 적용
               "        ABS(IFNULL(m.violence_score_avg, 0) - ?) * ? + " +  // 액션 가중치 적용
               "        ABS(IFNULL(s.horror_score_avg, 0) - ?) * ? + " +  // 스릴 가중치 적용
               "        ABS(IFNULL(s.sexual_score_avg, 0) - ?) * ?) AS weighted_score_diff " +  // 감성 가중치 적용
               "FROM movies m " +
               "LEFT JOIN movie_stats s ON m.id = s.movie_id " +
               "JOIN movie_genres mg ON m.id = mg.movie_id " +
               "WHERE m.id != ? " +
               "  AND m.rated IN (" + ratedPlaceholders + ") " +
               "GROUP BY m.id, m.title, m.rated, m.rating, m.violence_score_avg, s.horror_score_avg, s.sexual_score_avg " +
               "HAVING genre_match_count >= 1 " +
               "ORDER BY genre_match_count DESC, weighted_score_diff ASC " +
               "LIMIT 10";
       System.out.println("[DEBUG] 실행된 쿼리: " + sql);

       List<Object> params = new ArrayList<>();

       params.addAll(genres);             // 장르 매칭
       params.add(userRatingAvg);         // 평가지표
       params.add(ratingWeight);          // 작품성 가중치
       params.add(violenceScoreAvg);      // 폭력성
       params.add(violenceWeight);        // 액션 가중치
       params.add(horrorScoreAvg);        // 공포성
       params.add(horrorWeight);          // 스릴 가중치
       params.add(sexualScoreAvg);        // 선정성
       params.add(sexualWeight);          // 감성 가중치
       params.add(baseMovieId);           // 기준 영화 제외
       params.addAll(allowedRatings);     // 허용 등급

       System.out.println("[DEBUG] 추천 요청 - 기준 영화 ID: " + baseMovieId);
       System.out.println("[DEBUG] 유저 평균 점수 - rating: " + userRatingAvg 
           + ", violence: " + violenceScoreAvg 
           + ", horror: " + horrorScoreAvg 
           + ", sexual: " + sexualScoreAvg);
       System.out.println("[DEBUG] 유저 선호 장르: " + genres);

       return jdbcTemplate.query(sql, params.toArray(), (rs, rowNum) -> {
           StatDTO dto = new StatDTO();
           dto.setMovieId(rs.getLong("movie_id"));
           dto.setTitle(rs.getString("title"));
           dto.setRated(rs.getString("rated"));
           dto.setUserRatingAvg(rs.getDouble("rating"));
           dto.setViolenceScoreAvg(rs.getDouble("violence_score_avg"));
           dto.setHorrorScoreAvg(rs.getDouble("horror_score_avg"));
           dto.setSexualScoreAvg(rs.getDouble("sexual_score_avg"));
           dto.setPosterPath(rs.getString("poster_path")); 
           return dto;
       });
    }
    
  
    public Map<String, Double> findGlobalAverageScores() {
        String sql = "SELECT " +
                     "  COALESCE(AVG(m.rating), 5.0) as avg_rating, " +
                     "  COALESCE(AVG(m.violence_score_avg), 5.0) as avg_violence, " +
                     "  COALESCE(AVG(ms.horror_score_avg), 5.0) as avg_horror, " +
                     "  COALESCE(AVG(ms.sexual_score_avg), 5.0) as avg_sexual " +
                     "FROM movies m " +
                     "LEFT JOIN movie_stats ms ON m.id = ms.movie_id";

        // queryForObject 대신 query 메소드와 ResultSetExtractor를 사용해 더 안전하게 처리합니다.
        return jdbcTemplate.query(sql, (ResultSetExtractor<Map<String, Double>>) rs -> {
            Map<String, Double> averages = new HashMap<>();
            if (rs.next()) {
                averages.put("rating", rs.getDouble("avg_rating"));
                averages.put("violence", rs.getDouble("avg_violence"));
                averages.put("horror", rs.getDouble("avg_horror"));
                averages.put("sexual", rs.getDouble("avg_sexual"));
            }
            return averages;
        });
    }
    
    // 찜기능과 연계
    public Map<Long, List<String>> findGenresByMovieIds(List<Long> movieIds) {
        if (movieIds == null || movieIds.isEmpty()) return Collections.emptyMap();
        
        String sql = "SELECT movie_id, genre FROM movie_genres WHERE movie_id IN (:movieIds)";
        Map<String, Object> params = Collections.singletonMap("movieIds", movieIds);

        // ResultSetExtractor를 사용해 Map<MovieID, List<Genre>> 형태로 변환
        return namedParameterJdbcTemplate.query(sql, params, rs -> {
            Map<Long, List<String>> resultMap = new HashMap<>();
            while (rs.next()) {
                long movieId = rs.getLong("movie_id");
                String genre = rs.getString("genre");
                resultMap.computeIfAbsent(movieId, k -> new ArrayList<>()).add(genre);
            }
            return resultMap;
        });
               
    }
    
//영화 ID 리스트를 받아, runtime의 평균을 계산
    public Double findAverageRuntimeByMovieIds(List<Long> movieIds) {
        if (movieIds == null || movieIds.isEmpty()) return 0.0;
        
        // DB에서는 runtime 문자열을 그대로 가져옵니다.
        String sql = "SELECT runtime FROM movies WHERE id IN (:movieIds)";
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("movieIds", movieIds);
        
        // runtime 문자열 리스트를 가져옵니다.
        List<String> runtimeStrings = namedParameterJdbcTemplate.queryForList(sql, params, String.class);
        
        if (runtimeStrings.isEmpty()) return 0.0;
        
        // Java 코드 내에서 숫자만 추출하여 평균을 계산합니다.
        List<Integer> runtimes = new ArrayList<Integer>();
        for (String runtimeStr : runtimeStrings) {
            if (runtimeStr != null && !runtimeStr.isEmpty()) {
                try {
                    // 문자열에서 숫자 아닌 것을 모두 제거
                    String numericStr = runtimeStr.replaceAll("[^0-9]", "");
                    if (!numericStr.isEmpty()) {
                        runtimes.add(Integer.parseInt(numericStr));
                    }
                } catch (NumberFormatException e) {
                    // 숫자로 변환할 수 없는 경우, 로그를 남기고 무시
                    System.out.println("[WARN] Runtime 포맷 변환 실패: " + runtimeStr);
                }
            }
        }
        
        if (runtimes.isEmpty()) return 0.0;        
        // 평균 계산
        double sum = 0;
        for (Integer time : runtimes) {
            sum += time;
        }        
        return sum / runtimes.size();
    }
    
//영화 ID 리스트를 받아, 등장하는 감독별로 영화 수를 카운트하여 맵으로 반환
 public Map<String, Long> findDirectorCountsByMovieIds(List<Long> movieIds) {
     if (movieIds == null || movieIds.isEmpty()) return Collections.emptyMap();

     String sql = "SELECT a.name, COUNT(ma.movie_id) as count " +
                  "FROM movie_actors ma JOIN actors a ON ma.actor_id = a.id " +
                  "WHERE ma.movie_id IN (:movieIds) AND (ma.role_type = 'DIRECTOR' OR ma.role_type = '감독') " +
                  "GROUP BY a.id, a.name";
     Map<String, Object> params = new HashMap<String, Object>();
     params.put("movieIds", movieIds);

     return namedParameterJdbcTemplate.query(sql, params, new ResultSetExtractor<Map<String, Long>>() {
         @Override
         public Map<String, Long> extractData(ResultSet rs) throws SQLException {
             Map<String, Long> directorCounts = new HashMap<String, Long>();
             while (rs.next()) {
                 directorCounts.put(rs.getString("name"), rs.getLong("count"));
             }
             return directorCounts;
         }
     });
 }

//영화 ID 리스트를 받아, 전체 평점(movies.rating)의 평균을 계산
 public Double findAverageRatingByMovieIds(List<Long> movieIds) {
     if (movieIds == null || movieIds.isEmpty()) return 0.0;
     
     String sql = "SELECT AVG(rating) FROM movies WHERE id IN (:movieIds)";
     Map<String, Object> params = new HashMap<String, Object>();
     params.put("movieIds", movieIds);
     Double avg = namedParameterJdbcTemplate.queryForObject(sql, params, Double.class);
     return avg == null ? 0.0 : avg;
 }
 

/**
 * 영화 ID 리스트를 받아, 각 영화의 평점을 맵으로 반환합니다.
 * @param movieIds 영화 ID 리스트
 * @return Map<영화ID, 평점>
 */
public Map<Long, Double> findRatingsByMovieIds(List<Long> movieIds) {
    if (movieIds == null || movieIds.isEmpty()) return Collections.emptyMap();
    
    String sql = "SELECT id, rating FROM movies WHERE id IN (:movieIds)";
    Map<String, Object> params = new HashMap<String, Object>();
    params.put("movieIds", movieIds);

    return namedParameterJdbcTemplate.query(sql, params, new ResultSetExtractor<Map<Long, Double>>() {
        @Override
        public Map<Long, Double> extractData(ResultSet rs) throws SQLException {
            Map<Long, Double> movieRatings = new HashMap<Long, Double>();
            while (rs.next()) {
                movieRatings.put(rs.getLong("id"), rs.getDouble("rating"));
            }
            return movieRatings;
        }
    });
    
    
}

public double findAverageActorBirthYearByMovieIds(List<Long> cartMovieIds) {
	// TODO Auto-generated method stub
	return 0;
}


    
}

