package com.springmvc.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.springmvc.domain.RecentCommentDTO;
import com.springmvc.domain.movie;
import com.springmvc.repository.movieRepository;
import com.springmvc.repository.ReviewRepository;

@Service
public class movieService {

    private static final Logger logger = LoggerFactory.getLogger(movieService.class);

    private final movieRepository movieRepository;
    private final ReviewRepository reviewRepository;

    public movieService(movieRepository movieRepository, ReviewRepository reviewRepository) {
        this.movieRepository = movieRepository;
        this.reviewRepository = reviewRepository;
    }

    public List<movie> findAll() {
        logger.debug("movieService.findAll() 호출.");
        List<movie> movies = movieRepository.findAll();
        logger.debug("DB에서 {}개의 영화 목록을 가져왔습니다.", movies.size());
        return movies;
    }
    
    public List<movie> getAllRecommendedMovies() {
        logger.debug("movieService.getAllRecommendedMovies() 호출: 모든 추천 랭킹 영화 조회.");
        return movieRepository.findAllRecommendedMovies();
    }

    public movie findById(Long id) {
        logger.debug("movieService.findById({}) 호출.", id);
        movie movie = movieRepository.findById(id);
        if (movie != null) {
            logger.debug("영화 ID {} 찾음: {}", id, movie.getTitle());
        } else {
            logger.debug("영화 ID {} 찾을 수 없음.", id);
        }
        return movie;
    }

    // 25.08.04 coco030
    public boolean existsByApiId(String apiId) {
        return findByApiId(apiId) != null;
    }
    
    
    public movie findByApiId(String apiId) {
        logger.debug("movieService.findByApiId({}) 호출.", apiId);
        movie movie = movieRepository.findByApiId(apiId);
        if (movie != null) {
            logger.debug("API ID {}에 해당하는 영화 찾음: {}", apiId, movie.getTitle());
        } else {
            logger.debug("API ID {}에 해당하는 영화 찾을 수 없음.", apiId);
        }
        return movie;
    }

    public void save(movie movie) {
        logger.debug("movieService.save() 호출: 영화 제목 = {}", movie.getTitle());

        movieRepository.save(movie);
        logger.info("영화 '{}'가 DB에 저장되었습니다.", movie.getTitle());

        Long movieId = movie.getId();
        if (movieId == null) {
            logger.error("❌ 저장된 영화의 ID가 null입니다. genre 매핑 불가.");
            return;
        }

        // genre 문자열 → 배열로 분리해서 movie_genres에 매핑
        String genreString = movie.getGenre();
        if (genreString != null && !genreString.trim().isEmpty()) {
            String[] genreArray = genreString.split(",\\s*"); 
            for (String genre : genreArray) {
                if (!genre.isEmpty()) {
                    logger.debug("→ 장르 '{}'를 movie_genres에 매핑 중...", genre);
                    movieRepository.insertGenreMapping(movieId, genre);
                }
            }
            logger.info("영화 '{}'의 장르 매핑 완료. (총 {}개)", movie.getTitle(), genreArray.length);
        } else {
            logger.warn("영화 '{}'에 장르 정보가 없습니다. movie_genres 매핑 생략됨.", movie.getTitle());
        }
    }

    public void update(movie movie) {
        logger.debug("movieService.update() 호출: 영화 ID = {}", movie.getId());
        movieRepository.update(movie);
        logger.info("영화 ID {}가 업데이트되었습니다.", movie.getId());
    }

    public void delete(Long id) {
        logger.debug("movieService.delete() 호출: 영화 ID = {}", id);
        movieRepository.delete(id);
        logger.info("영화 ID {}가 삭제되었습니다.", id);
    }
    
    public Map<LocalDate, List<movie>> getUpcomingMoviesForMonth(int year, int month) { // 07-31: 추가된 메서드
        logger.debug("movieService.getUpcomingMoviesForMonth({}, {}) 호출.", year, month); // 07-31: 추가된 메서드

        LocalDate startDate = LocalDate.of(year, month, 1); // 07-31: 추가된 메서드
        LocalDate endDate = LocalDate.of(year, month, startDate.lengthOfMonth()); // 07-31: 추가된 메서드

        List<movie> movies = movieRepository.findByReleaseDateBetween(startDate, endDate); // 07-31: 추가된 메서드

        Map<LocalDate, List<movie>> result = movies.stream() // 07-31: 추가된 메서드
                .collect(Collectors.groupingBy(movie::getReleaseDate)); // 07-31: 추가된 메서드

        logger.debug("getUpcomingMoviesForMonth 결과: {}개의 날짜에 영화가 존재합니다.", result.size()); // 07-31: 추가된 메서드
        return result; // 07-31: 추가된 메서드
    }


    public List<movie> getTop6RecommendedMovies() {
        logger.debug("movieService.getTop6RecommendedMovies() 호출.");
        return movieRepository.findTop6RecommendedMoviesByLikeCount();
    }

    public List<RecentCommentDTO> getRecentComments() {
        logger.debug("movieService.getRecentComments() 호출: ReviewRepository로부터 모든 최근 상호작용 데이터 요청.");

        List<RecentCommentDTO> allRecentInteractions = reviewRepository.findTop3RecentComments();
        logger.debug("movieService.getRecentComments() 결과: {}개의 상호작용 수신.", allRecentInteractions.size());

        for (RecentCommentDTO comment : allRecentInteractions) {
            if (comment.getMovieId() != null) {
                movie movieInfo = movieRepository.findTitleAndPosterById(comment.getMovieId());
                if (movieInfo != null) {
                    comment.setMovieName(movieInfo.getTitle());
                    comment.setPosterPath(movieInfo.getPosterPath());
                    logger.debug("  - 코멘트 ID: {}, 영화 정보 채움: '{}' (ID: {})", comment.getReviewId(), movieInfo.getTitle(), movieInfo.getId());
                } else {
                    comment.setMovieName("알 수 없는 영화");
                    comment.setPosterPath("/resources/images/movies/256px-No-Image-Placeholder.png");
                    logger.warn("  - 코멘트 ID: {}, 영화 ID {}에 해당하는 영화 정보를 찾을 수 없어 기본값 설정.", comment.getReviewId(), comment.getMovieId());
                }
            } else {
                comment.setMovieName("알 수 없는 영화");
                comment.setPosterPath("/resources/images/movies/256px-No-Image-Placeholder.png");
                logger.warn("  - 코멘트 ID: {}, 영화 ID가 null이어서 기본값 설정.", comment.getReviewId());
            }
        }

        List<RecentCommentDTO> filteredComments = allRecentInteractions.stream()
                .filter(comment -> comment.getReviewContent() != null && !comment.getReviewContent().trim().isEmpty())
                .collect(Collectors.toList());

        logger.debug("필터링 후 '최근 달린 댓글' 결과: {}개의 코멘트 반환.", filteredComments.size());
        return filteredComments;
    }

    public List<movie> getAllRecentMovies() {
        return movieRepository.findAllRecentMovies(); 
    }

    public List<movie> getRecentMovies(int limit) {
        logger.debug("movieService.getRecentMovies({}) 호출.", limit);
        return movieRepository.findRecentMovies(limit);
    }

    public List<movie> getAllUpcomingMovies() {
        logger.debug("movieService.getAllUpcomingMovies() 호출: 모든 개봉 예정 영화 조회.");
        return movieRepository.findAllUpcomingMovies();
    }

    public List<movie> getUpcomingMoviesWithDday() {
        logger.debug("movieService.getUpcomingMoviesWithDday() 호출.");
        return movieRepository.getUpcomingMoviesWithDday();
    }
}