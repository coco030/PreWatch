<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="header-left">
    <a href="${pageContext.request.contextPath}/">PreWatch</a> 
    <%-- 관리자에게만 '영화 등록' 링크 표시 (컨트롤러에서 접근 차단도 함께 동작) --%>
    <c:if test="${userRole == 'ADMIN'}">
        | <a href="${pageContext.request.contextPath}/movies">영화 목록</a>
        | <a href="${pageContext.request.contextPath}/movies/new">영화 등록</a>
    </c:if>
</div>