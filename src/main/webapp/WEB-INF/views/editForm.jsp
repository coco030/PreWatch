<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("회원정보 수정 뷰 진입"); %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>비밀번호 변경</title>
    <%-- Bootstrap CSS --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <%-- Custom CSS --%>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        .container {
            min-height: calc(100vh - 120px); /* 헤더와 푸터 높이를 제외한 최소 높이 */
        }
    </style>
</head>
<body class="bg-light">

    <%-- 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="container d-flex justify-content-center align-items-center py-5">
        <div class="card shadow-sm" style="width: 100%; max-width: 450px;">
            <div class="card-body p-4 p-md-5">
                <h2 class="card-title text-center fw-bold mb-4">비밀번호 변경</h2>

                <%-- 서버 측 에러 메시지 표시 --%>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger" role="alert">
                        ${errorMessage}
                    </div>
                </c:if>

                <!-- 비밀번호 수정 폼 -->
                <form id="passwordUpdateForm" action="${pageContext.request.contextPath}/member/updatePassword" method="post">
                    <input type="hidden" name="id" value="${sessionScope.loginMember.id}" />

                    <div class="mb-3">
                        <label for="pw" class="form-label">새 비밀번호</label>
                        <input type="password" class="form-control" id="pw" name="pw" required>
                        <div id="passwordHelp" class="form-text">
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="confirmPassword" class="form-label">새 비밀번호 확인</label>
                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        <div id="passwordMatchFeedback" class="invalid-feedback">
                            비밀번호가 일치하지 않습니다.
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 mb-3">비밀번호 수정</button>
                </form>

                <hr>

                <div class="text-center">
                    <p class="text-muted mb-2">계정을 비활성화하시겠습니까?</p>
                    <!-- 회원 탈퇴 폼 -->
                    <form id="deactivationForm" action="${pageContext.request.contextPath}/member/deactivateUser" method="post" class="mt-2">
                        <button type="button" class="btn btn-outline-danger w-100" data-bs-toggle="modal" data-bs-target="#deactivationModal">
                            회원 탈퇴
                        </button>
                    </form>
                </div>

            </div>
        </div>
    </div>

    <!-- 회원 탈퇴 확인 Modal -->
    <div class="modal fade" id="deactivationModal" tabindex="-1" aria-labelledby="deactivationModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deactivationModalLabel">회원 탈퇴 확인</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="fw-bold text-danger">정말로 탈퇴하시겠습니까?</p>
                    <p>이 작업은 되돌릴 수 없으며, 모든 회원 정보가 영구적으로 삭제됩니다.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-danger" id="confirmDeactivateBtn">확인하고 탈퇴</button>
                </div>
            </div>
        </div>
    </div>


    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    
    <%-- JQuery & Bootstrap JS --%>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

    <script>
    $(function() {
        // 비밀번호 일치 여부 확인 함수
        function validatePassword() {
            const password = $('#pw').val();
            const confirmPassword = $('#confirmPassword').val();
            
            if (password && confirmPassword) { // 두 필드 모두 값이 있을 때만 검사
                if (password === confirmPassword) {
                    $('#confirmPassword').removeClass('is-invalid').addClass('is-valid');
                    $('#passwordMatchFeedback').hide();
                    return true;
                } else {
                    $('#confirmPassword').removeClass('is-valid').addClass('is-invalid');
                    $('#passwordMatchFeedback').show();
                    return false;
                }
            }
            // 한쪽이라도 비어있으면 유효성 상태를 초기화
            $('#confirmPassword').removeClass('is-valid is-invalid');
            return false;
        }

        // 비밀번호 확인 입력창에서 키를 누를 때마다 검사
        $('#pw, #confirmPassword').on('keyup', function() {
            validatePassword();
        });

        // 비밀번호 변경 폼 제출 시 최종 검사
        $('#passwordUpdateForm').on('submit', function(event) {
            if (!validatePassword()) {
                event.preventDefault(); // 폼 제출 중단
                alert('새 비밀번호와 비밀번호 확인이 일치하지 않습니다.');
                $('#confirmPassword').focus();
            }
        });

        // 회원 탈퇴 모달의 '확인하고 탈퇴' 버튼 클릭 시
        $('#confirmDeactivateBtn').on('click', function() {
            // 실제 회원 탈퇴 form을 제출
            $('#deactivationForm').submit();
        });
    });
    </script>
</body>
</html>