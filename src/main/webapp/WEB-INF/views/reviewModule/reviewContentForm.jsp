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

<!-- 로그인한 경우에만 보여줄 리뷰 작성/출력창 -->
<c:if test="${not empty loginMember}">
  <!-- 리뷰 작성창 -->
   <h6 class="mb-2 fw-bold"><i class="fas fa-pen me-1"></i>나의 리뷰</h6>
  <div id="reviewWriteBox" class="mb-3" <c:if test="${not empty myReview.reviewContent}">style="display:none;"</c:if>>
    <textarea id="reviewContentInput"
              class="form-control border-0 border-bottom rounded-0 px-1 py-2 auto-expand"
              rows="1"
              placeholder="아직 리뷰를 남기지 않으셨어요."
              style="resize: vertical; overflow-y: hidden; background-color: transparent;"></textarea>
    <div class="text-end mt-2">
      <button class="btn btn-dark btn-sm" id="saveReviewContentBtn">리뷰 저장</button>
    </div>
  </div>

  <!-- 리뷰 출력창 -->
  <div id="reviewDisplayBox" class="mb-3" <c:if test="${empty myReview.reviewContent}">style="display:none;"</c:if>>
    <div id="reviewContentBox" class="mb-2" style="white-space: pre-wrap;">
      ${fn:escapeXml(myReview.reviewContent)}
    </div>
    <div class="text-end">
      <button class="btn btn-outline-secondary btn-sm me-2" id="editReviewBtn">수정</button>
      <button class="btn btn-outline-danger btn-sm" id="deleteReviewBtn">삭제</button>
    </div>
  </div>
</c:if>

<!-- 로그인하지 않은 경우에만 알림 -->
<c:if test="${empty loginMember}">
<a href="${pageContext.request.contextPath}/auth/login" style="text-decoration: none;">
  <div class="alert alert-light text-secondary mb-3 mt-2 small" role="alert">
      리뷰를 작성하시려면 로그인해주세요.
  </div>
</a>
</c:if>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const input = document.getElementById("reviewContentInput");
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
    }

    // 저장 버튼
    const saveBtn = document.getElementById("saveReviewContentBtn");
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
