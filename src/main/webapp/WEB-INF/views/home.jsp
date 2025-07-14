<<<<<<< HEAD
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("홈 뷰 진입"); %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Welcome</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <%-- 공통 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />
    <%-- 메인 콘텐츠 (영화 목록 등) --%>
    <main>
        <hr>
        <h2>영화 목록 (나중에 추가될 영역)</h2>
        <div>
            <!-- 영화 목록 (나중에 추가될 영역) -->
        </div>
    </main>

    <%-- 3. 공통 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
=======
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("홈 뷰 진입"); %>
<% Object loginMember = session.getAttribute("loginMember"); %>
<html>
	<head>
		<title>Welcome</title>
</head>
	<body>	
<% if (loginMember == null) { %>    
    <a href="${pageContext.request.contextPath}/join">회원가입</a>
    <a href="${pageContext.request.contextPath}/login">로그인</a>
    <p>환영합니다</p>
<% } else { %>
    <% com.springmvc.domain.Member member = (com.springmvc.domain.Member) loginMember; %>
    <p><%= member.getId() %>님, 환영합니다.</p><br>

    <!-- 25.07.10 추가함 -->
    <a href="${pageContext.request.contextPath}/member/mypage">나의 영화 기록</a>
    <a href="${pageContext.request.contextPath}/member/editForm">비밀번호 수정</a>
    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
<% } %>	
	</body>
>>>>>>> 4bceb7925953eb4af9533b02996141ec23f73d07
</html>