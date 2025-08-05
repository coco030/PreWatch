package com.springmvc.repository;

import java.util.List;

import com.springmvc.domain.WarningTag;

public interface WarningTagRepository {
	

    // [관리자용] 모든 주의 요소 문장들을 가져오기 (체크박스 목록 생성용)
    List<WarningTag> getAllWarningTags();

    // [사용자용] 특정 영화에 해당하는 주의 요소 문장들만 가져오기
    List<WarningTag> getWarningTagsByMovieId(long movieId);

    // [관리자용] 특정 영화의 기존 주의 요소 매핑 정보를 모두 삭제하기 (업데이트 전 초기화)
    void deleteWarningTagsByMovieId(long movieId);

    // [관리자용] 특정 영화에 새로운 주의 요소 매핑 정보들을 추가하기
    void addWarningTagsToMovie(long movieId, List<Long> warningTagIds);

}
