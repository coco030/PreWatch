 <!-- 팀원 작업영역 -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- header-center.jsp -->
<div class="header-center">
    <form action="${pageContext.request.contextPath}/search" method="get">
        <input type="text" name="query" placeholder="영화 검색..." />
        <button type="submit">검색</button>
    </form>
</div>
