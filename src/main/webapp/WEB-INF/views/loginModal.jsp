<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- 로그인 모달 (iframe 없이 form 직접 렌더링) -->
<div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="loginModalLabel">로그인</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
      </div>
      <div class="modal-body">
        <!-- 동적으로 표시될 안내 문구 -->
        <p class="mb-3 text-muted text-center login-message" style="display: none;"></p>

        <form action="${pageContext.request.contextPath}/auth/login" method="post">
          <div class="mb-3">
            <label for="id" class="form-label">아이디</label>
            <input type="text" class="form-control" id="id" name="id" required>
          </div>
          <div class="mb-3">
            <label for="password" class="form-label">비밀번호</label>
            <input type="password" class="form-control" id="password" name="password" required>
          </div>
          <button type="submit" class="btn btn-primary w-100">로그인</button>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- 🔽 Bootstrap 모달에 맞게 동적으로 제목 + 메시지 바꾸는 스크립트 -->
<script>
  const loginModal = document.getElementById('loginModal');

  if (loginModal) {
    loginModal.addEventListener('show.bs.modal', function (event) {
      const trigger = event.relatedTarget;

      const title = trigger.getAttribute('data-title') || '로그인';
      const message = trigger.getAttribute('data-message') || '';

      const modalTitle = loginModal.querySelector('.modal-title');
      const messageTag = loginModal.querySelector('.login-message');

      if (modalTitle) {
        modalTitle.textContent = title;
      }

      if (messageTag) {
        if (message.trim() !== '') {
          messageTag.textContent = message;
          messageTag.style.display = 'block';
        } else {
          messageTag.style.display = 'none';
        }
      }
    });
  }
</script>
