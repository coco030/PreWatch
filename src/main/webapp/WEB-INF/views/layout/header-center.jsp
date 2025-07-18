<%--
    파일명: layout/header-center.jsp
    설명:
        이 JSP 파일은 home.jsp 헤더의 중앙 영역, 즉 검색창 부분을 정의합니다.
    목적:
        - 웹사이트 상단에 통합 검색 기능을 제공하여 사용자가 쉽게 영화를 찾을 수 있게 하기 위해.

    
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="header-center">
    <form action="${pageContext.request.contextPath}/search" method="get">
    <!--`movieController.java`의 `searchMoviesFromHeader` (GET /search) 메서드로 요청을 보냄.
       - 이 컨트롤러 메서드는 `apiSearchPage.jsp` 뷰를 반환하여 검색 결과를 표시함. -->
        <input type="text" name="query" placeholder="영화 검색..." />
        <!--  사용자가 입력한 검색어를 서버로 전송할 때 쓸 name으로 query 사용.
            - `movieController`에서 이 값을 받아 API 검색에 활용. -->
        <button type="submit">검색</button>
    </form>
</div>