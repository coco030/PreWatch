<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="header-right-wrapper">
    <c:set var="headerLoginMember" value="${sessionScope.loginMember}" />
    <c:choose>
        <c:when test="${empty headerLoginMember}">
            <!-- 비로그인 상태 -->
            <a href="${pageContext.request.contextPath}/member/join"
               class="header-auth-link"
               data-auth-frame-url="${pageContext.request.contextPath}/member/join"
               data-auth-frame-title="회원가입">회원가입</a>
            <a href="${pageContext.request.contextPath}/auth/login"
               class="header-auth-link header-auth-link-primary"
               data-auth-frame-url="${pageContext.request.contextPath}/auth/login"
               data-auth-frame-title="로그인">로그인</a>
        </c:when>
        <c:when test="${headerLoginMember.role eq 'ADMIN'}">
            <!-- 관리자 메뉴 -->
            <a href="${pageContext.request.contextPath}/movies">관리자 대시보드</a>
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
            <span>관리자 (${headerLoginMember.id})님</span>
        </c:when>
        <c:otherwise>
            <!-- 회원 메뉴 -->
            <a href="${pageContext.request.contextPath}/member/wishlist">보고 싶어요</a>
            <a href="${pageContext.request.contextPath}/member/mypage">나의 기록</a>
            <a href="${pageContext.request.contextPath}/member/editForm">정보수정</a>
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
            <span>회원 (${headerLoginMember.id})님</span>
        </c:otherwise>
    </c:choose>
</div>
