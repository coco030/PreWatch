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
import com.springmvc.repository.ReviewRepository;
import com.springmvc.repository.movieRepository;

@Service
public class movieService {

    private static final Logger logger = LoggerFactory.getLogger(movieService.class);

    private final movieRepository movieRepository;
    private final ReviewRepository reviewRepository;

    public movieService(movieRepository movieRepository, ReviewRepository reviewRepository) {
        this.movieRepository = movieRepository;
        this.reviewRepository = reviewRepository;
    }

    // 모든 영화 목록 조회
    public List<movie> findAll() {
        logger.debug("movieService.findAll() 호출.");
        List<movie> movies = movieRepository.findAll();
        logger.debug("DB에서 {}개의 영화 목록을 가져왔습니다.", movies.size());
        return movies;
    }
    
    // 모든 추천 랭킹 영화 조회
    public List<movie> getAllRecommendedMovies() {
        logger.debug("movieService.getAllRecommendedMovies() 호출: 모든 추천 랭킹 영화 조회.");
        return movieRepository.findAllRecommendedMovies();
    }

    // ID로 영화 조회
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

    // API ID로 영화 존재 여부 확인
    public boolean existsByApiId(String apiId) {
        return findByApiId(apiId) != null;
    }
    
    // API ID로 영화 조회
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

    // 영화 저장
    public void save(movie movie) {
        logger.debug("movieService.save() 호출: 영화 제목 = {}", movie.getTitle());
        movieRepository.save(movie);
        logger.info("영화 '{}'가 DB에 저장되었습니다.", movie.getTitle());

        Long movieId = movie.getId();
        if (movieId == null) {
            logger.error("❌ 저장된 영화의 ID가 null입니다. genre 매핑 불가.");
            return;
        }

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

    // 영화 업데이트
    public void update(movie movie) {
        logger.debug("movieService.update() 호출: 영화 ID = {}", movie.getId());
        movieRepository.update(movie);
        logger.info("영화 ID {}가 업데이트되었습니다.", movie.getId());
    }

    // 영화 삭제
    public void delete(Long id) {
        logger.debug("movieService.delete() 호출: 영화 ID = {}", id);
        movieRepository.delete(id);
        logger.info("영화 ID {}가 삭제되었습니다.", id);
    }
    
    // 특정 월의 개봉 예정 영화 조회
    public Map<LocalDate, List<movie>> getUpcomingMoviesForMonth(int year, int month) {
        logger.debug("movieService.getUpcomingMoviesForMonth({}, {}) 호출.", year, month);
        
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = LocalDate.of(year, month, startDate.lengthOfMonth());
        
        List<movie> movies = movieRepository.findByReleaseDateBetween(startDate, endDate);
        
        Map<LocalDate, List<movie>> result = movies.stream()
                .collect(Collectors.groupingBy(movie::getReleaseDate));
                
        logger.debug("getUpcomingMoviesForMonth 결과: {}개의 날짜에 영화가 존재합니다.", result.size());
        return result;
    }

    // 메인 페이지: 최근 3개 영화 조회
    public List<movie> getRecentMovies(int limit) {
        logger.debug("movieService.getRecentMovies({}) 호출.", limit);
        return movieRepository.findRecentMovies(limit);
    }

    // 메인 페이지: 찜 개수 기준 상위 6개 영화 조회
    public List<movie> getTop6RecommendedMovies() {
        logger.debug("movieService.getTop6RecommendedMovies() 호출.");
        return movieRepository.findTop6RecommendedMoviesByLikeCount();
    }
    
    // 메인 페이지: 최근 댓글 3개 조회
    public List<RecentCommentDTO> getRecentComments() {
        logger.debug("movieService.getRecentComments() 호출: ReviewRepository로부터 최근 3개의 코멘트 데이터 요청.");
        List<RecentCommentDTO> allRecentInteractions = reviewRepository.findTop3RecentComments();
        
        for (RecentCommentDTO comment : allRecentInteractions) {
            if (comment.getMovieId() != null) {
                movie movieInfo = movieRepository.findTitleAndPosterById(comment.getMovieId());
                if (movieInfo != null) {
                    comment.setMovieName(movieInfo.getTitle());
                    comment.setPosterPath(movieInfo.getPosterPath());
                } else {
                    comment.setMovieName("알 수 없는 영화");
                    comment.setPosterPath("/resources/images/movies/256px-No-Image-Placeholder.png");
                }
            } else {
                comment.setMovieName("알 수 없는 영화");
                comment.setPosterPath("/resources/images/movies/256px-No-Image-Placeholder.png");
            }
        }
        
        List<RecentCommentDTO> filteredComments = allRecentInteractions.stream()
            .filter(comment -> comment.getReviewContent() != null && !comment.getReviewContent().trim().isEmpty())
            .collect(Collectors.toList());

        logger.debug("필터링 후 '최근 달린 댓글' 결과: {}개의 코멘트 반환.", filteredComments.size());
        return filteredComments;
    }

   // 모든 댓글 조회 (페이징, 검색 포함)
   //(8/5 추가)
    public List<RecentCommentDTO> getAllRecentCommentsWithDetails(int page, int limit, String sortBy, String sortDirection, String searchType, String keyword) {
        int offset = (page - 1) * limit;
        List<RecentCommentDTO> comments = reviewRepository.findAllRecentCommentsWithDetails(offset, limit, sortBy, sortDirection, searchType, keyword);

        for (RecentCommentDTO comment : comments) {
            if (comment.getMovieId() != null) {
                movie movieInfo = movieRepository.findTitleAndPosterById(comment.getMovieId());
                if (movieInfo != null) {
                    comment.setMovieName(movieInfo.getTitle());
                    comment.setPosterPath(movieInfo.getPosterPath());
                } else {
                    comment.setMovieName("알 수 없는 영화");
                    comment.setPosterPath("/resources/images/movies/256px-No-Image-Placeholder.png");
                }
            } else {
                comment.setMovieName("알 수 없는 영화");
                comment.setPosterPath("/resources/images/movies/256px-No-Image-Placeholder.png");
            }
        }
        return comments;
    }

    //(8/5 추가)
    // 전체 댓글 수 조회
    public int getTotalCommentCount(String searchType, String keyword) {
        return reviewRepository.countAllComments(searchType, keyword);
    }
    
    // 모든 최근 등록 영화 조회
    public List<movie> getAllRecentMovies() {
        return movieRepository.findAllRecentMovies();
    }
    
    // 모든 개봉 예정 영화 조회
    public List<movie> getAllUpcomingMovies() {
        logger.debug("movieService.getAllUpcomingMovies() 호출: 모든 개봉 예정 영화 조회.");
        return movieRepository.findAllUpcomingMovies();
    }
    
    // D-day를 포함한 개봉 예정 영화 조회
    public List<movie> getUpcomingMoviesWithDday() {
        logger.debug("movieService.getUpcomingMoviesWithDday() 호출.");
        return movieRepository.getUpcomingMoviesWithDday();
    }
}