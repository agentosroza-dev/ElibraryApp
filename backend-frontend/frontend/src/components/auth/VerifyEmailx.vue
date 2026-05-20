<template>
  <div class="login-page">
    <div class="login-box">
      <div class="card card-outline card-primary">
        <div class="card-header text-center">
          <router-link to="/" class="h1"><b>Admin</b>LTE</router-link>
        </div>
        <div class="card-body">
          <p class="login-box-msg">Email Verification</p>
          <div class="alert alert-info">
            <p>Processing email verification...</p>
          </div>
          <p class="mb-1">
            <router-link :to="{ name: 'auth.signin' }" class="text-center"
              >Go back to login</router-link
            >
          </p>
          <p class="mb-0">
            <router-link :to="{ name: 'auth.signup' }" class="text-center"
              >Register a new membership</router-link
            >
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup></script>
