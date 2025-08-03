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