<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- 부트스트랩 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- 영화 ID & 로그인 체크 -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="memberId" value="${loginMember.id}" />
</c:if>

<h6 class="mb-2 fw-bold"><i class="fas fa-pen me-1"></i>나의 리뷰</h6>

<!-- ✅ style 중복 방지용 분리 처리 -->
<c:set var="writeBoxStyle" value="max-width: 600px; width: 100%;" />
<c:if test="${not empty loginMember && not empty myReview.reviewContent}">
    <c:set var="writeBoxStyle" value="display: none; max-width: 600px; width: 100%;" />
</c:if>

<!-- ✅ 리뷰 작성창 -->
<div id="reviewWriteBox"
     class="mb-3"
     style="${writeBoxStyle}"
     <c:if test="${empty loginMember}">
         data-bs-toggle="modal"
         data-message="리뷰 작성은 로그인 후 이용하실 수 있어요"
         data-bs-target="#loginModal"
         style="max-width: 600px; width: 100%; cursor: pointer;"
     </c:if>>
  
  <textarea id="reviewContentInput"
            class="form-control border-0 border-bottom rounded-0 px-1 py-2 auto-expand"
            rows="1"
            placeholder="<c:choose>
                            <c:when test='${empty loginMember}'>로그인 후 리뷰를 작성하실 수 있어요.</c:when>
                            <c:otherwise>아직 리뷰를 남기지 않으셨어요.</c:otherwise>
                         </c:choose>"
            style="width: 100%; resize: vertical; overflow-y: hidden; background-color: transparent;"
            <c:if test="${empty loginMember}">readonly</c:if>></textarea>

  <div class="text-end mt-2">
    <button class="btn btn-dark btn-sm" id="saveReviewContentBtn"
            <c:if test="${empty loginMember}">disabled</c:if>>리뷰 저장</button>
  </div>
</div>

<!-- ✅ 로그인한 경우에만 리뷰 출력창 보이기 -->
<c:if test="${not empty loginMember && not empty myReview.reviewContent}">
  <div id="reviewDisplayBox" class="mb-3">
    <div id="reviewContentBox" class="mb-2" style="white-space: pre-wrap;">
      ${fn:escapeXml(myReview.reviewContent)}
    </div>
    <div class="text-end">
      <button class="btn btn-outline-secondary btn-sm me-2" id="editReviewBtn">수정</button>
      <button class="btn btn-outline-danger btn-sm" id="deleteReviewBtn">삭제</button>
    </div>
  </div>
</c:if>

<!-- 로그인 모달 -->
<jsp:include page="/WEB-INF/views/loginModal.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const input = document.getElementById("reviewContentInput");
    const saveBtn = document.getElementById("saveReviewContentBtn");
    const content = "${fn:escapeXml(myReview.reviewContent)}";

    // textarea 자동 높이 확장
    if (input) {
        input.value = content;
        input.style.height = "auto";
        input.style.height = input.scrollHeight + "px";

        input.addEventListener("input", function () {
            this.style.height = "auto";
            this.style.height = this.scrollHeight + "px";
        });

        // ⬇️ Enter 키 입력 시 저장 (단, Shift+Enter는 줄바꿈 유지)
        input.addEventListener("keydown", function (event) {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault(); // 줄바꿈 방지
                if (saveBtn) saveBtn.click(); // 저장 처리
            }
        });
    }

    // 저장 버튼
    if (saveBtn) {
        saveBtn.addEventListener("click", function () {
            const content = input.value.trim();
            const movieId = document.getElementById("movieId").value;

            if (content === "") {
                alert("리뷰 내용을 입력해주세요.");
                return;
            }

            fetch("${pageContext.request.contextPath}/review/saveContent", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId, reviewContent: content })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("리뷰가 저장되었습니다.");
                    document.getElementById("reviewContentBox").textContent = content;
                    document.getElementById("reviewWriteBox").style.display = "none";
                    document.getElementById("reviewDisplayBox").style.display = "block";
                } else {
                    alert(data.message || "저장 실패");
                }
            });
        });
    }

    // 수정 버튼
    const editBtn = document.getElementById("editReviewBtn");
    if (editBtn) {
        editBtn.addEventListener("click", function () {
            document.getElementById("reviewWriteBox").style.display = "block";
            document.getElementById("reviewDisplayBox").style.display = "none";
        });
    }

    // 삭제 버튼
    const deleteBtn = document.getElementById("deleteReviewBtn");
    if (deleteBtn) {
        deleteBtn.addEventListener("click", function () {
            if (!confirm("정말 리뷰를 삭제하시겠습니까?")) return;

            const movieId = document.getElementById("movieId").value;

            fetch("${pageContext.request.contextPath}/review/deleteReview", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("삭제되었습니다.");
                    input.value = "";
                    input.style.height = "auto";
                    document.getElementById("reviewWriteBox").style.display = "block";
                    document.getElementById("reviewDisplayBox").style.display = "none";
                } else {
                    alert(data.message || "삭제 실패");
                }
            });
        });
    }
});
</script>
