package com.springmvc.service;

import com.springmvc.domain.movie;
import com.springmvc.repository.userCartRepository;
import com.springmvc.repository.movieRepository; // movieRepository를 통해 like_count를 업데이트 (but 직접 호출 제거)
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// UserCartService 클래스: 찜(User Cart)과 관련된 비즈니스 로직을 구현합니다.
// 목적: 찜 추가/제거, 찜 상태 확인, 찜 목록 조회 등의 기능을 제공하고, Repository에 데이터베이스 작업을 위임합니다.
@Service
public class userCartService {

    private static final Logger logger = LoggerFactory.getLogger(userCartService.class);

    private final userCartRepository userCartRepository;
    private final movieRepository movieRepository; // 찜한 영화의 상세 정보를 조회하고 like_count를 (트리거를 통해) 업데이트하기 위함

    @Autowired
    public userCartService(userCartRepository userCartRepository, movieRepository movieRepository) {
        this.userCartRepository = userCartRepository;
        this.movieRepository = movieRepository;
        logger.info("userCartService 초기화 완료.");
    }

    /**
     * addOrRemoveMovie 메서드: 특정 회원의 찜 목록에 영화를 추가하거나 제거합니다.
     * 목적: 사용자가 하트 아이콘을 클릭하여 찜 상태를 토글하는 기능을 구현합니다.
     * @param memberId 찜을 수행하는 회원의 ID
     * @param movieId 찜 대상 영화의 ID
     * @return 찜 목록에 추가되었으면 { "status": "added", "newLikeCount": N }, 제거되었으면 { "status": "removed", "newLikeCount": N } 반환
     */
    @Transactional // 트랜잭션 관리: 찜 추가/제거와 like_count 업데이트를 하나의 트랜잭션으로 묶음
    public Map<String, Object> addOrRemoveMovie(String memberId, Long movieId) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (userCartRepository.isMovieInCart(memberId, movieId)) { // 이미 찜한 영화인지 확인
                userCartRepository.removeMovieFromCart(memberId, movieId); // 이미 찜했으면 제거
                // ⭐ movieRepository.decrementLikeCount(movieId); // 트리거 사용 시 이 라인 제거 ⭐
                result.put("status", "removed");
                logger.info("회원 {}의 찜 목록에서 영화 ID {}를 제거했습니다.", memberId, movieId);
            } else {
                userCartRepository.addMovieToCart(memberId, movieId); // 찜하지 않았다면 추가
                // ⭐ movieRepository.incrementLikeCount(movieId); // 트리거 사용 시 이 라인 제거 ⭐
                result.put("status", "added");
                logger.info("회원 {}의 찜 목록에 영화 ID {}를 추가했습니다.", memberId, movieId);
            }

            // ⭐ 업데이트된 like_count를 다시 조회하여 반환 (트리거에 의해 업데이트된 최신 값) ⭐
            // 이 findById 호출은 트리거가 like_count를 업데이트한 후에 실행되어야 합니다.
            // @Transactional 덕분에 DB 커밋 전에도 최신 값을 읽을 수 있습니다.
            movie updatedMovie = movieRepository.findById(movieId);
            result.put("newLikeCount", updatedMovie != null ? updatedMovie.getLikeCount() : 0);
            return result;
        } catch (Exception e) {
            logger.error("찜 토글 처리 중 오류 발생 (memberId={}, movieId={}): {}", memberId, movieId, e.getMessage(), e);
            throw new RuntimeException("찜 처리 중 오류가 발생했습니다.", e); // 런타임 예외 발생 시 트랜잭션 롤백
        }
    }

    /**
     * isMovieLiked 메서드: 특정 영화가 특정 회원의 찜 목록에 있는지 확인합니다.
     * 목적: JSP에서 하트 아이콘의 표시 상태(빈 하트/꽉 찬 하트)를 결정할 때 사용됩니다.
     * @param memberId 확인할 회원의 ID
     * @param movieId 확인할 영화의 ID
     * @return 찜 목록에 있으면 true, 없으면 false
     */
    @Transactional(readOnly = true)
    public boolean isMovieLiked(String memberId, Long movieId) {
        return userCartRepository.isMovieInCart(memberId, movieId);
    }

    /**
     * getLikedMovies 메서드: 특정 회원이 찜한 모든 영화의 상세 정보를 조회합니다.
     * 목적: 위시리스트에 사용자가 찜한 영화 목록을 보여줄 때 사용됩니다.
     * @param memberId 찜 목록을 조회할 회원의 ID
     * @return 찜한 영화들의 movie 객체 리스트
     */
    @Transactional(readOnly = true)
    public List<movie> getLikedMovies(String memberId) {
        logger.debug("회원 {}이 찜한 영화 목록 조회 시작.", memberId);
        List<Long> likedMovieIds = userCartRepository.findMovieIdsInCartByMemberId(memberId);
        List<movie> likedMovies = new ArrayList<>();

        if (!likedMovieIds.isEmpty()) {
            for (Long movieId : likedMovieIds) {
                movie movie = movieRepository.findById(movieId);
                if (movie != null) {
                    movie.setIsLiked(true); // 찜 목록에서는 항상 찜된 상태로 표시
                    likedMovies.add(movie);
                } else {
                    logger.warn("찜 목록에 있는 영화 ID {}를 찾을 수 없습니다. (DB에서 삭제되었을 수 있음)", movieId);
                }
            }
        }
        logger.info("회원 {}이 찜한 영화 {}개 상세 정보 가져옴.", memberId, likedMovies.size());
        return likedMovies;
    }
}