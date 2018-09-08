import Vue from 'vue'
import Router from 'vue-router'
import QtumSwap from '@/components/QtumSwap'
import formLoading from 'vue2-form-loading'

Vue.use(Router)
Vue.use(formLoading)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'QtumSwap',
      component: QtumSwap
    }
  ]
})
