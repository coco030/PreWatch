package com.springmvc.service;

import java.util.List;
import java.util.stream.Collectors; // Stream API 사용을 위해 임포트

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.springmvc.domain.RecentCommentDTO;
import com.springmvc.domain.movie; // movie 엔티티/도메인 클래스
import com.springmvc.repository.movieRepository; // 기존 movieRepository
import com.springmvc.repository.ReviewRepository; // ReviewRepository 인터페이스

// movieService 클래스: 영화(movie) 관련 비즈니스 로직 구현.
// 목적: Controller와 Repository 사이에서 비즈니스 규칙 적용 및 트랜잭션 관리.
@Service // Spring 빈으로 등록
public class movieService {

    private static final Logger logger = LoggerFactory.getLogger(movieService.class); // Logger 객체 초기화

    private final movieRepository movieRepository; // movieRepository 주입 필드
    private final ReviewRepository reviewRepository; // ReviewRepository 인터페이스 주입 필드

    // 생성자를 통한 movieRepository와 ReviewRepository 주입.
    // 목적: 불변성 확보 및 테스트 용이성 증가.
    // Spring 4.3+ 에서는 단일 생성자의 경우 @Autowired를 생략할 수 있습니다.
    public movieService(movieRepository movieRepository, ReviewRepository reviewRepository) {
        this.movieRepository = movieRepository;
        this.reviewRepository = reviewRepository;
    }

    // findAll 메서드: 모든 영화 목록 조회.
    // 목적: Controller에서 호출, 실제 데이터 조회는 Repository에 위임.
    public List<movie> findAll() {
        logger.debug("movieService.findAll() 호출.");
        List<movie> movies = movieRepository.findAll();
        logger.debug("DB에서 {}개의 영화 목록을 가져왔습니다.", movies.size());
        return movies;
    }

    // findById 메서드: 특정 ID 영화 정보 조회.
    // 목적: Controller에서 영화 상세 페이지 요청 시 호출.
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

    /**
     * findByApiId 메서드: API ID (imdbID)를 사용하여 DB에서 영화 조회.
     * 목적: 외부 API 검색 결과에 로컬 평점/잔혹도 덮어씌울 때 사용.
     * @param apiId OMDb 등 외부 API의 고유 ID.
     * @return 해당 apiId를 가진 movie 객체, 없으면 null.
     */
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

 // 07.28 coco030 genre 문자열 → 배열로 분리해서 movie_genres에 매핑 추가
    // save 메서드: 새 영화 정보 저장.
    // 목적: Controller에서 영화 등록 요청 시 호출.
    public void save(movie movie) {
        logger.debug("movieService.save() 호출: 영화 제목 = {}", movie.getTitle());

        movieRepository.save(movie);
        logger.info("영화 '{}'가 DB에 저장되었습니다.", movie.getTitle());


        // 저장된 movie의 ID 조회
        Long movieId = movie.getId();
        if (movieId == null) {
            logger.error("❌ 저장된 영화의 ID가 null입니다. genre 매핑 불가.");
            return;
        }

        // genre 문자열 → 배열로 분리해서 movie_genres에 매핑
        String genreString = movie.getGenre();
        if (genreString != null && !genreString.trim().isEmpty()) {
            String[] genreArray = genreString.split(",\\s*"); // 쉼표 + 공백 기준
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

    // update 메서드: 기존 영화 정보 업데이트.
    // 목적: Controller에서 영화 수정 요청 시 호출.
    public void update(movie movie) {
        logger.debug("movieService.update() 호출: 영화 ID = {}", movie.getId());
        movieRepository.update(movie);
        logger.info("영화 ID {}가 업데이트되었습니다.", movie.getId());
    }

    // delete 메서드: 특정 영화 정보 삭제.
    // 목적: Controller에서 영화 삭제 요청 시 호출.
    public void delete(Long id) {
        logger.debug("movieService.delete() 호출: 영화 ID = {}", id);
        movieRepository.delete(id);
        logger.info("영화 ID {}가 삭제되었습니다.", id);
    }

    // --- ⭐ 기존 메서드: 추천 랭킹 영화 조회 (like_count 기준) ⭐ (7-24 오후12:41 추가 된 코드)
    /**
     * 찜 개수(like_count)를 기준으로 정렬된 상위 5개 추천 영화 목록을 조회합니다. (7-24 오후12:41 추가 된 코드)
     * @return 찜 개수 기준 상위 5개 추천 영화 목록 (7-24 오후12:41 추가 된 코드)
     */
    public List<movie> getTop6RecommendedMovies() { // (7-24 오후12:41 추가 된 코드)
        logger.debug("movieService.getTop6RecommendedMovies() 호출."); // (7-24 오후12:41 추가 된 코드)
        return movieRepository.findTop6RecommendedMoviesByLikeCount(); // (7-24 오후12:41 추가 된 코드)
    } // (7-24 오후12:41 추가 된 코드)
    // --- 새로운 메서드: 최근 등록된 평가된 평가와 댓글 조회 ---
    /**
     * 최근 등록된 평가 목록 중 실제 댓글 내용이 있는 항목만 가져옵니다.
     * @return reviewContent가 비어있지 않은 RecentCommentDTO 리스트
     */
    public List<RecentCommentDTO> getRecentComments() {
        logger.debug("movieService.getRecentComments() 호출: ReviewRepository로부터 모든 최근 상호작용 데이터 요청.");
        // ReviewRepository에서 모든 최근 댓글/평가/찜 기록을 가져옵니다.
        // 이 메서드 (findTop3RecentComments)가 현재 댓글 내용이 없는 DTO도 포함하여 반환한다고 가정합니다.
        List<RecentCommentDTO> allRecentInteractions = reviewRepository.findTop3RecentComments();
        logger.debug("movieService.getRecentComments() 결과: {}개의 상호작용 수신.", allRecentInteractions.size());

        // Stream API를 사용하여 reviewContent가 비어있지 않은 항목만 필터링합니다.
        List<RecentCommentDTO> filteredComments = allRecentInteractions.stream()
                .filter(comment -> comment.getReviewContent() != null && !comment.getReviewContent().trim().isEmpty())
                .collect(Collectors.toList());

        logger.debug("필터링 후 '최근 달린 댓글' 결과: {}개의 코멘트 반환.", filteredComments.size());
        return filteredComments;
    }

    // --- 새로운 메서드: 최근 등록된 영화 조회 (개봉일 기준) ---
    public List<movie> getRecentMovies(int limit) {
        logger.debug("movieService.getRecentMovies({}) 호출.", limit);
        return movieRepository.findRecentMovies(limit);
    }

    // ============ coco030이 추가한 내역 25.07.24 오후 3시쯤====
    // 최근 개봉 예정작
    public List<movie> getUpcomingMoviesWithDday() {
        logger.debug("movieService.getUpcomingMoviesWithDday({}) 호출.");
        return movieRepository.getUpcomingMoviesWithDday();
    }
// ===========coco030이 추가한 내역 끝 ==== ///
}