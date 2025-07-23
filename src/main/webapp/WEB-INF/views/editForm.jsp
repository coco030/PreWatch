<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("회원정보 수정 뷰 진입"); %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원정보 수정 페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<body class="bg-white">

    <%-- 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="container d-flex justify-content-center align-items-center flex-column" style="min-height: 80vh;">
        <div class="w-100" style="max-width: 400px;">
            <h2 class="text-center mb-4">비밀번호 변경</h2>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>

            <!-- 비밀번호 수정 폼 -->
            <form action="${pageContext.request.contextPath}/member/updatePassword" method="post">
                <input type="hidden" name="id" value="${sessionScope.loginMember.id}" />

                <div class="mb-3">
                    <label for="pw" class="form-label">새 비밀번호</label>
                    <input type="password" class="form-control" id="pw" name="pw" required>
                </div>

                <div class="mb-3">
                    <label for="confirmPassword" class="form-label">새 비밀번호 확인</label>
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                </div>

                <button type="submit" class="btn btn-primary w-100">비밀번호 수정</button>
            </form>

            <!-- 회원 탈퇴 폼 -->
            <form action="${pageContext.request.contextPath}/member/deactivateUser" method="post" class="mt-3">
                <button type="submit" class="btn btn-outline-danger w-100">회원 탈퇴</button>
            </form>
        </div>
    </div>

    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>
