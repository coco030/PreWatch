package com.springmvc.repository;

import com.springmvc.domain.movie; // 찜한 영화 정보를 가져올 때 사용될 수 있습니다.
import java.util.List;

// UserCartRepository 인터페이스: 찜(User Cart) 데이터에 접근하는 메서드들을 정의합니다.
// 목적: 사용자의 찜 목록에 영화를 추가/삭제하거나, 찜 상태를 확인하고, 찜 목록을 조회하는 기능을 제공합니다.
public interface userCartRepository {

    // addMovieToCart 메서드: 특정 회원의 찜 목록에 영화를 추가합니다. (C - Create)
    void addMovieToCart(String memberId, Long movieId);

    // removeMovieFromCart 메서드: 특정 회원의 찜 목록에서 영화를 제거합니다. (D - Delete)
    void removeMovieFromCart(String memberId, Long movieId);

    // isMovieInCart 메서드: 특정 영화가 특정 회원의 찜 목록에 있는지 확인합니다. (R - Read One)
    boolean isMovieInCart(String memberId, Long movieId);

    // findMovieIdsInCartByMemberId 메서드: 특정 회원이 찜한 모든 영화의 ID 목록을 조회합니다. (R - Read Some)
    // 목적: 마이페이지 등에서 찜 목록에 있는 영화들을 효율적으로 가져오기 위함.
    List<Long> findMovieIdsInCartByMemberId(String memberId);

    // 25.08.05 coco030
    int countLikedMovies(String memberId);
    //25.08.05 coco030 
    List<Long> findLikedMovieIdsPaged(String memberId, int limit, int offset);

}