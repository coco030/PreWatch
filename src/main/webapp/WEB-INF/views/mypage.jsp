<%--
    파일명: mypage.jsp
    설명:
        이 JSP 파일은 로그인한 사용자의 마이페이지입니다.
        현재는 단순히 "나의 영화 리뷰나 별점 목록"이라는 텍스트만 표시하고 있으며,
        이 페이지에서 리뷰나 별점을 수정/삭제하는 기능은 제공하지 않는다고 명시되어 있습니다.
        향후 사용자별 영화 리뷰 및 평점 기록을 보여주는 기능이 추가될 예정입니다.

    목적:
        - 로그인한 사용자가 자신의 활동 기록(영화 리뷰, 별점 등)을 확인할 수 있는 개인 공간을 제공합니다.
        - 개인화된 경험의 시작점을 제시합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% System.out.println("mypage 뷰 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>mypage</title>
</head>
<body>
나의 영화 리뷰나 별점 목록 (볼 수만 있고 이 페이지에서 수정삭제 불가)
</body>