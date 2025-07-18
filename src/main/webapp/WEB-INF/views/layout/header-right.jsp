<%--
    파일명: header-right.jsp
    설명:
        이 JSP 파일은 header.jsp의 오른쪽 영역을 정의합니다.

    목적:
        - 사용자의 인증 상태와 권한에 따라 표시되는 값을 다르게 함.
        - 권한에 따라 접근 가능한 정보를 제공 및 제한하기 위함.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // 세션에서 loginMember 객체와 userRole 값을 가져옴.
    // 세션에서 정보를 긁어와 다른 메뉴를 보여주기 위함.
    Object loginMemberObj = session.getAttribute("loginMember"); 
    String userRole = (String) session.getAttribute("userRole"); 
    com.springmvc.domain.Member loginMember = null;
    if (loginMemberObj != null) {
        loginMember = (com.springmvc.domain.Member) loginMemberObj;
    }
%>
<div class="header-right-wrapper">

<% if (loginMember == null) { %>

<a href="${pageContext.request.contextPath}/member/join">회원가입</a>
<!-- `MemberController.java`의 `showJoinForm` (GET /member/join) 메서드로 연결. -->

<a href="${pageContext.request.contextPath}/auth/login">로그인</a>
<!-- `LoginController.java`의 `showLoginForm` (GET /auth/login) 메서드로 연결됩니다. -->

<% }
    // 로그인한 경우 (회원 또는 관리자)
    else { %>
        <c:if test="${userRole != null && userRole eq 'ADMIN'}"> 
            <%-- 관리자만 사용 가능한 기능을 사용할 수 있음--%>
            <%--uerRole이 DB에 등록되어있는 운영자 값 'ADMIN'에 해당할 경우만 실행 --%>
            
            <a href="${pageContext.request.contextPath}/movies">관리자 대시보드</a> |
            <%--`movieController.java`의 `list` (GET /movies) 메서드로 연결. --%>
            
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
            <%-- `LoginController.java`의 `logout` (GET /auth/logout) 메서드로 연결. --%>
        </c:if>
        <c:if test="${userRole != null && userRole eq 'MEMBER'}">
            <%-- 회원만 사용 가능한 기능을 사용할 수 있음--%>
            <a href="${pageContext.request.contextPath}/member/mypage">나의 영화 기록</a> |
            <%--`MemberController.java`의 `showMyPage` (GET /member/mypage) 메서드로 연결. --%>
            
 			<%--`MemberController.java`의 `showEditForm` (GET /member/editForm) 메서드로 연결 --%>
           	<a href="${pageContext.request.contextPath}/member/editForm">회원 정보 수정</a>| 
            
          	<%--  `LoginController.java`의 `logout` (GET /auth/logout) 메서드로 연결. --%>
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>

        </c:if>

        <span style="margin-left: 10px; color: #555;">
            <c:if test="${userRole eq 'ADMIN'}">관리자</c:if>
            <c:if test="${userRole eq 'MEMBER'}">회원</c:if>
            (${loginMember.id})님
        </span>
    <% } %>
</div>