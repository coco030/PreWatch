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
    <form action="${pageContext.request.contextPath}/search" method="get" class="search-form">
        <div class="search-input-wrapper">
            <input type="text" 
                   name="query" 
                   placeholder="영화 검색..." 
                   class="search-input"
                   autocomplete="off" />
			<button type="submit" class="search-btn" title="검색">
			    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
			        <circle cx="11" cy="11" r="8"></circle>
			        <path d="M 21 21l-4.35-4.35"></path>
			    </svg>
			</button>
        </div>
    </form>
</div>