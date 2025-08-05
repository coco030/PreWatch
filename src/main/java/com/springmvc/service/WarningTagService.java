package com.springmvc.service;

import java.util.List;
import java.util.Map;

import com.springmvc.domain.WarningTag;

public interface WarningTagService {

    // [관리자용] 관리자 페이지에 보여줄 모든 주의 요소 목록 가져오기
    List<WarningTag> getAllWarningTags();

    // [사용자용] 영화 상세 페이지에 보여줄 특정 영화의 주의 요소 목록 가져오기
    // Map<String, List<String>> 형태로 가공해서 Controller에 전달
    Map<String, List<String>> getGroupedWarningTagsByMovieId(long movieId);

    // [관리자용] 특정 영화에 설정된 주의 요소 ID 목록 가져오기 (체크박스 pre-check용)
    List<Long> getWarningTagIdsByMovieId(long movieId);

    // [관리자용] 영화의 주의 요소를 업데이트하는 핵심 로직
    // (기존 정보 지우고, 새로 받은 정보로 저장)
    void updateMovieWarningTags(long movieId, List<Long> warningTagIds);
}